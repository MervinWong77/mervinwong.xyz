import Foundation

#if canImport(Darwin)
import Darwin
#endif

/// Best-effort process memory samples. Never throws; nil means unavailable.
public enum ProcessMemorySampler {
    public static func residentByteCount() -> UInt64? {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return UInt64(info.resident_size)
        #else
        return nil
        #endif
    }

    /// Physical footprint (closer to Activity Monitor “Memory”). Nil when unavailable.
    public static func physicalFootprintByteCount() -> UInt64? {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return UInt64(info.phys_footprint)
        #else
        return nil
        #endif
    }
}
