import Foundation
import Testing
@testable import CopyCatEngine

@Suite("Candidate SQLite store")
struct CandidateSQLiteStoreTests {
    @Test("Inserts and loads colliding sizes from disk")
    func insertAndLoad() throws {
        let store = try CandidateSQLiteStore(batchSize: 10)
        defer { try? store.closeAndDelete() }

        try store.insert(size: 100, path: "/tmp/a.txt", createdAt: nil, modifiedAt: nil)
        try store.insert(size: 100, path: "/tmp/b.txt", createdAt: nil, modifiedAt: nil)
        try store.insert(size: 200, path: "/tmp/c.txt", createdAt: nil, modifiedAt: nil)
        try store.finishInserts()

        #expect(store.insertedCount == 3)
        let sizes = try store.collidingSizes()
        #expect(sizes == [100])
        let files = try store.scannedFiles(forSize: 100)
        #expect(files.count == 2)
        #expect(Set(files.map(\.filename)) == ["a.txt", "b.txt"])
        #expect(files.map(\.url.path) == files.map(\.url.path).sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        })
    }

    @Test("Loads same-size files in stable path order")
    func pathOrderedLoad() throws {
        let store = try CandidateSQLiteStore(batchSize: 10)
        defer { try? store.closeAndDelete() }

        try store.insert(size: 50, path: "/tmp/z/end.txt", createdAt: nil, modifiedAt: nil)
        try store.insert(size: 50, path: "/tmp/a/start.txt", createdAt: nil, modifiedAt: nil)
        try store.insert(size: 50, path: "/tmp/m/mid.txt", createdAt: nil, modifiedAt: nil)
        try store.finishInserts()

        let paths = try store.scannedFiles(forSize: 50).map(\.url.path)
        #expect(paths == ["/tmp/a/start.txt", "/tmp/m/mid.txt", "/tmp/z/end.txt"])
    }

    @Test("closeAndDelete removes the database directory")
    func deletesOnClose() throws {
        let store = try CandidateSQLiteStore()
        let url = store.fileURL
        let dir = url.deletingLastPathComponent()
        #expect(FileManager.default.fileExists(atPath: url.path))
        try store.closeAndDelete()
        #expect(!FileManager.default.fileExists(atPath: dir.path))
    }

    @Test("Candidate store is created only under temporaryDirectory")
    func storeLivesInSystemTemp() throws {
        let store = try CandidateSQLiteStore()
        defer { try? store.closeAndDelete() }
        let tempRoot = FileManager.default.temporaryDirectory
            .resolvingSymlinksInPath()
            .standardizedFileURL
            .path
        let storePath = store.fileURL
            .resolvingSymlinksInPath()
            .standardizedFileURL
            .path
        #expect(storePath.hasPrefix(tempRoot + "/") || storePath.hasPrefix(tempRoot))
        #expect(storePath.contains("CopyCatScan-"))
        #expect(!storePath.contains("/Volumes/"))
    }
}
