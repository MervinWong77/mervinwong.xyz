import Foundation
import SQLite3

/// Disk-backed candidate index for Pass 2.
/// Lives in a per-scan temp file and is deleted on close.
public final class CandidateSQLiteStore: @unchecked Sendable {
    public private(set) var insertedCount: Int = 0

    private var db: OpaquePointer?
    private var insertStatement: OpaquePointer?
    private let databaseURL: URL
    private var pendingInTransaction: Int = 0
    private let batchSize: Int
    private var isOpen: Bool = false

    public init(batchSize: Int = 500) throws {
        self.batchSize = max(batchSize, 1)
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("CopyCatScan-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        databaseURL = dir.appendingPathComponent("candidates.sqlite")

        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(databaseURL.path, &handle, flags, nil) == SQLITE_OK, let handle else {
            throw CandidateStoreError.openFailed(databaseURL.path)
        }
        db = handle
        isOpen = true

        try exec("PRAGMA journal_mode=WAL;")
        try exec("PRAGMA synchronous=NORMAL;")
        try exec(
            """
            CREATE TABLE candidates (
                id INTEGER PRIMARY KEY,
                size INTEGER NOT NULL,
                path TEXT NOT NULL,
                created_at REAL,
                modified_at REAL
            );
            """
        )
        try exec("CREATE INDEX idx_candidates_size ON candidates(size);")
        try exec("BEGIN TRANSACTION;")

        var stmt: OpaquePointer?
        let sql = "INSERT INTO candidates(size, path, created_at, modified_at) VALUES (?, ?, ?, ?);"
        guard sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else {
            throw CandidateStoreError.prepareFailed(lastErrorMessage())
        }
        insertStatement = stmt
    }

    deinit {
        try? closeAndDelete()
    }

    public var fileURL: URL { databaseURL }

    /// On-disk size of the temporary candidate database (best-effort).
    public var databaseByteCount: UInt64? {
        guard isOpen else { return nil }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: databaseURL.path),
              let size = attrs[.size] as? NSNumber else {
            return nil
        }
        return size.uint64Value
    }

    /// Largest colliding size-bucket row count (for diagnostics).
    public func largestCollidingBucketCount() throws -> Int {
        guard let db, isOpen else { throw CandidateStoreError.closed }
        let sql = """
            SELECT COUNT(*) AS c FROM candidates
            GROUP BY size
            HAVING COUNT(*) >= 2
            ORDER BY c DESC
            LIMIT 1;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else {
            throw CandidateStoreError.prepareFailed(lastErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int64(stmt, 0))
    }

    public func insert(
        size: UInt64,
        path: String,
        createdAt: Date?,
        modifiedAt: Date?
    ) throws {
        guard db != nil, let insertStatement, isOpen else {
            throw CandidateStoreError.closed
        }

        sqlite3_reset(insertStatement)
        sqlite3_clear_bindings(insertStatement)
        sqlite3_bind_int64(insertStatement, 1, Int64(bitPattern: size))
        sqlite3_bind_text(insertStatement, 2, path, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if let createdAt {
            sqlite3_bind_double(insertStatement, 3, createdAt.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(insertStatement, 3)
        }
        if let modifiedAt {
            sqlite3_bind_double(insertStatement, 4, modifiedAt.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(insertStatement, 4)
        }

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw CandidateStoreError.insertFailed(lastErrorMessage())
        }

        insertedCount += 1
        pendingInTransaction += 1
        if pendingInTransaction >= batchSize {
            try flushBatch()
        }
    }

    public func finishInserts() throws {
        try flushBatch()
    }

    /// Distinct sizes that still have at least two rows (hashable buckets).
    public func collidingSizes() throws -> [UInt64] {
        guard let db, isOpen else { throw CandidateStoreError.closed }
        let sql = """
            SELECT size FROM candidates
            GROUP BY size
            HAVING COUNT(*) >= 2
            ORDER BY size;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else {
            throw CandidateStoreError.prepareFailed(lastErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }

        var sizes: [UInt64] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let raw = sqlite3_column_int64(stmt, 0)
            sizes.append(UInt64(bitPattern: raw))
        }
        return sizes
    }

    /// Loads one size bucket as `ScannedFile` values (paths only for that size).
    public func scannedFiles(forSize size: UInt64) throws -> [ScannedFile] {
        guard let db, isOpen else { throw CandidateStoreError.closed }
        // Path order clusters directory locality for Balanced sequential hashing.
        let sql = """
            SELECT path, created_at, modified_at FROM candidates
            WHERE size = ?
            ORDER BY path COLLATE NOCASE;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK, let stmt else {
            throw CandidateStoreError.prepareFailed(lastErrorMessage())
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_int64(stmt, 1, Int64(bitPattern: size))

        var files: [ScannedFile] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let cPath = sqlite3_column_text(stmt, 0) else { continue }
            let path = String(cString: cPath)
            let url = URL(fileURLWithPath: path)
            let created: Date? = sqlite3_column_type(stmt, 1) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(stmt, 1))
            let modified: Date? = sqlite3_column_type(stmt, 2) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2))
            files.append(
                ScannedFile(
                    url: url,
                    filename: url.lastPathComponent,
                    extension: url.pathExtension,
                    size: size,
                    createdDate: created,
                    modifiedDate: modified
                )
            )
        }
        return files
    }

    public func closeAndDelete() throws {
        guard isOpen else { return }
        isOpen = false

        if let insertStatement {
            sqlite3_finalize(insertStatement)
            self.insertStatement = nil
        }
        if let db {
            // Roll back any open transaction, then close.
            _ = sqlite3_exec(db, "ROLLBACK;", nil, nil, nil)
            sqlite3_close(db)
            self.db = nil
        }

        let dir = databaseURL.deletingLastPathComponent()
        try? FileManager.default.removeItem(at: dir)
    }

    private func flushBatch() throws {
        guard let db, pendingInTransaction > 0 else { return }
        try exec("COMMIT;")
        try exec("BEGIN TRANSACTION;")
        pendingInTransaction = 0
        _ = db
    }

    private func exec(_ sql: String) throws {
        guard let db else { throw CandidateStoreError.closed }
        var errorMessage: UnsafeMutablePointer<CChar>?
        let status = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if status != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "SQLite error \(status)"
            sqlite3_free(errorMessage)
            throw CandidateStoreError.execFailed(message)
        }
    }

    private func lastErrorMessage() -> String {
        guard let db else { return "database closed" }
        if let cString = sqlite3_errmsg(db) {
            return String(cString: cString)
        }
        return "unknown SQLite error"
    }
}

public enum CandidateStoreError: Error, LocalizedError, Sendable {
    case openFailed(String)
    case prepareFailed(String)
    case insertFailed(String)
    case execFailed(String)
    case closed

    public var errorDescription: String? {
        switch self {
        case .openFailed(let path): return "Could not open candidate database at \(path)"
        case .prepareFailed(let message): return "SQLite prepare failed: \(message)"
        case .insertFailed(let message): return "SQLite insert failed: \(message)"
        case .execFailed(let message): return "SQLite exec failed: \(message)"
        case .closed: return "Candidate database is closed"
        }
    }
}
