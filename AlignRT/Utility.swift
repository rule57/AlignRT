//
//  Utility.swift
//  AlignRT
//
//  Created by William Rule on 7/4/24.
//

//import Foundation
//import UIKit
//import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers
//
//class ImageUtility {
//    static func createGif(from images: [UIImage]) -> Data? {
//        guard !images.isEmpty else { return nil }
//
//        let frameProperties = [
//            kCGImagePropertyGIFDictionary as String: [
//                kCGImagePropertyGIFDelayTime as String: 0.2
//            ]
//        ]
//        let gifProperties = [
//            kCGImagePropertyGIFDictionary as String: [
//                kCGImagePropertyGIFLoopCount as String: 0
//            ]
//        ]
//
//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile.gif")
//
//        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.gif.identifier as CFString, images.count, nil) else { return nil }
//
//        for image in images {
//            let fixedImage = fixOrientation(image)
//            if let cgImage = fixedImage.cgImage {
//                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
//            }
//        }
//
//        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
//
//        guard CGImageDestinationFinalize(destination) else { return nil }
//
//        return try? Data(contentsOf: fileURL)
//    }
//
//    static func fixOrientation(_ image: UIImage) -> UIImage {
//        guard image.imageOrientation != .up else { return image }
//
//        var transform = CGAffineTransform.identity
//
//        switch image.imageOrientation {
//        case .down, .downMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
//            transform = transform.rotated(by: .pi)
//        case .left, .leftMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: 0)
//            transform = transform.rotated(by: .pi / 2)
//        case .right, .rightMirrored:
//            transform = transform.translatedBy(x: 0, y: image.size.height)
//            transform = transform.rotated(by: -.pi / 2)
//        default:
//            break
//        }
//
//        switch image.imageOrientation {
//        case .upMirrored, .downMirrored:
//            transform = transform.translatedBy(x: image.size.width, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        case .leftMirrored, .rightMirrored:
//            transform = transform.translatedBy(x: image.size.height, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        default:
//            break
//        }
//
//        guard let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace,
//              let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
//            return image
//        }
//
//        ctx.concatenate(transform)
//
//        switch image.imageOrientation {
//        case .left, .leftMirrored, .right, .rightMirrored:
//            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
//        default:
//            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        }
//
//        guard let newCgImage = ctx.makeImage() else { return image }
//        return UIImage(cgImage: newCgImage)
//    }
//}

import Foundation
import UIKit
import ImageIO
import MobileCoreServices


class Utility {
    /// Creates a GIF from an array of `UIImage` objects.
    /// - Parameter images: An array of `UIImage` objects.
    /// - Returns: `Data` representing the GIF or `nil` if the creation fails.
    static func createGif(from images: [UIImage]) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: 0.2
            ]
        ]
        let gifProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("animated.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, images.count, nil) else { return nil }
        
        for image in images {
            let fixedImage = fixOrientation(image)
            if let cgImage = fixedImage.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return try? Data(contentsOf: fileURL)
    }
    
    /// Fixes the orientation of a `UIImage`.
    /// - Parameter image: The `UIImage` to be fixed.
    /// - Returns: A new `UIImage` with the corrected orientation.
    static func fixOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        
        var transform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace,
              let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return image
        }
        
        ctx.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        guard let newCgImage = ctx.makeImage() else { return image }
        return UIImage(cgImage: newCgImage)
    }
}

