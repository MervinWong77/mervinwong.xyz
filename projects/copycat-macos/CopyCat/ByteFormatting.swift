import Foundation

enum ByteFormatting {
    static func string(from bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        let clamped = bytes > UInt64(Int64.max) ? Int64.max : Int64(bytes)
        return formatter.string(fromByteCount: clamped)
    }
}

func formattedBytes(_ bytes: UInt64) -> String {
    ByteFormatting.string(from: bytes)
}
