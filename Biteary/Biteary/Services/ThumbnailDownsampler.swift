//
//  ThumbnailDownsampler.swift
//  Biteary
//

import CryptoKit
import ImageIO
import UIKit

/// Thread-safe, memory-bounded image thumbnail downsampler backed by `ImageIO` and `NSCache`.
///
/// Decodes JPEG/HEIC/PNG `Data` directly into a downsampled `CGImage` without inflating
/// the full-resolution bitmap into memory, preserving EXIF orientation transforms.
final class ThumbnailDownsampler: @unchecked Sendable {
    static let shared = ThumbnailDownsampler()

    private let cache: NSCache<NSString, UIImage>

    init(countLimit: Int = 150, totalCostLimitBytes: Int = 50 * 1024 * 1024) {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "me.vincenzopicone.biteary.thumbnailCache"
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimitBytes
        self.cache = cache
    }

    /// Downsamples image data to fit within a target SwiftUI/UIKit point size and display scale.
    func downsample(data: Data, pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let longestSide = max(pointSize.width, pointSize.height)
        guard longestSide > 0, longestSide.isFinite else { return nil }
        let effectiveScale = (scale.isFinite && scale > 0) ? scale : 1.0
        let maxPixelSize = ceil(longestSide * effectiveScale)
        return downsample(data: data, maxPixelSize: maxPixelSize)
    }

    /// Downsamples image data so neither pixel dimension exceeds `maxPixelSize`.
    func downsample(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard !data.isEmpty, maxPixelSize > 0, maxPixelSize.isFinite else {
            return nil
        }

        let targetPixels = max(1, Int(ceil(maxPixelSize)))
        let key = cacheKey(for: data, maxPixelSize: targetPixels)

        if let cached = cache.object(forKey: key) {
            return cached
        }

        let sourceOptions: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            return nil
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: targetPixels
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions as CFDictionary) else {
            return nil
        }

        let thumbnail = UIImage(cgImage: cgImage)
        let decodedByteCost = cgImage.bytesPerRow * cgImage.height
        cache.setObject(thumbnail, forKey: key, cost: decodedByteCost)
        return thumbnail
    }

    /// Evicts all cached thumbnails from memory.
    func clearCache() {
        cache.removeAllObjects()
    }

    private func cacheKey(for data: Data, maxPixelSize: Int) -> NSString {
        let digest = SHA256.hash(data: data)
        let hexDigest = digest.map { String(format: "%02x", $0) }.joined()
        return "\(hexDigest)_\(maxPixelSize)" as NSString
    }
}
