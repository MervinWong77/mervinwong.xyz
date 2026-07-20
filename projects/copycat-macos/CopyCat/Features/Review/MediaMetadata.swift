import AVFoundation
import CoreMedia
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct MediaMetadata: Equatable, Sendable {
    var pixelWidth: Int?
    var pixelHeight: Int?
    var durationSeconds: Double?
    var codec: String?

    var resolutionLabel: String? {
        guard let w = pixelWidth, let h = pixelHeight, w > 0, h > 0 else { return nil }
        return "\(w)×\(h)"
    }

    var durationLabel: String? {
        guard let seconds = durationSeconds, seconds > 0, seconds.isFinite else { return nil }
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
}

enum MediaMetadataLoader {
    static func load(for url: URL) -> MediaMetadata {
        let ext = url.pathExtension.lowercased()
        if isImageExtension(ext) {
            return loadImage(url)
        }
        if isAVExtension(ext) {
            return loadAV(url)
        }
        return MediaMetadata()
    }

    private static func isImageExtension(_ ext: String) -> Bool {
        ["png", "jpg", "jpeg", "heic", "heif", "gif", "tif", "tiff", "bmp", "webp"].contains(ext)
    }

    private static func isAVExtension(_ ext: String) -> Bool {
        ["mp4", "mov", "m4v", "avi", "mkv", "mp3", "m4a", "aac", "wav", "aiff", "caf"].contains(ext)
    }

    private static func loadImage(_ url: URL) -> MediaMetadata {
        var meta = MediaMetadata()
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return meta
        }
        if let w = props[kCGImagePropertyPixelWidth] as? Int {
            meta.pixelWidth = w
        } else if let w = props[kCGImagePropertyPixelWidth] as? CGFloat {
            meta.pixelWidth = Int(w)
        }
        if let h = props[kCGImagePropertyPixelHeight] as? Int {
            meta.pixelHeight = h
        } else if let h = props[kCGImagePropertyPixelHeight] as? CGFloat {
            meta.pixelHeight = Int(h)
        }
        if let uti = CGImageSourceGetType(source) as String? {
            meta.codec = UTType(uti)?.preferredFilenameExtension?.uppercased() ?? UTType(uti)?.identifier
        }
        return meta
    }

    private static func loadAV(_ url: URL) -> MediaMetadata {
        var meta = MediaMetadata()
        let asset = AVURLAsset(url: url)

        let duration = asset.duration
        if duration.isNumeric && !duration.isIndefinite {
            let seconds = CMTimeGetSeconds(duration)
            if seconds.isFinite, seconds > 0 {
                meta.durationSeconds = seconds
            }
        }

        let videoTracks = asset.tracks(withMediaType: .video)
        if let track = videoTracks.first {
            let size = track.naturalSize.applying(track.preferredTransform)
            let width = Int(abs(size.width).rounded())
            let height = Int(abs(size.height).rounded())
            if width > 0, height > 0 {
                meta.pixelWidth = width
                meta.pixelHeight = height
            }
            meta.codec = codecName(from: track)
        } else if let track = asset.tracks(withMediaType: .audio).first {
            meta.codec = codecName(from: track)
        }
        return meta
    }

    private static func codecName(from track: AVAssetTrack) -> String? {
        for format in track.formatDescriptions {
            // formatDescriptions yields CMFormatDescription bridged as AnyObject.
            let description = format as! CMFormatDescription
            let fourCC = CMFormatDescriptionGetMediaSubType(description)
            let name = fourCCToString(fourCC)
            if !name.isEmpty { return name }
        }
        return nil
    }

    private static func fourCCToString(_ code: FourCharCode) -> String {
        let chars: [UInt8] = [
            UInt8((code >> 24) & 0xff),
            UInt8((code >> 16) & 0xff),
            UInt8((code >> 8) & 0xff),
            UInt8(code & 0xff),
        ]
        if let string = String(bytes: chars, encoding: .ascii) {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(code)
    }
}
