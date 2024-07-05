//
//  GifCreator.swift
//  AlignRT
//
//  Created by William Rule on 7/5/24.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import ImageIO
import MobileCoreServices
import UIKit

class GifCreator: ObservableObject {
    private let queue = DispatchQueue(label: "com.align.giftcreator.queue")

    func createAndUploadGif(for userId: String, completion: @escaping (Bool) -> Void) {
        queue.async {
            let storageRef = Storage.storage().reference().child("users/\(userId)/images")
            storageRef.listAll { [weak self] (result, error) in
                if let error = error {
                    print("Error listing images: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let self = self, let result = result else {
                    print("Error: result is nil")
                    completion(false)
                    return
                }

                let imageRefs = result.items

                var images: [UIImage] = []
                let group = DispatchGroup()

                for ref in imageRefs {
                    group.enter()
                    ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
                        defer { group.leave() }
                        if let error = error {
                            print("Error downloading image: \(error.localizedDescription)")
                            return
                        }
                        if let data = data, let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                }

                group.notify(queue: self.queue) {
                    if images.isEmpty {
                        print("No images found to create GIF")
                        completion(false)
                        return
                    }

                    if let gifData = self.createGif(from: images) {
                        let gifRef = Storage.storage().reference().child("users/\(userId)/post/profile.gif")
                        gifRef.putData(gifData, metadata: nil) { metadata, error in
                            if let error = error {
                                print("Error uploading GIF: \(error.localizedDescription)")
                                completion(false)
                                return
                            }
                            print("GIF uploaded successfully")
                            completion(true)
                        }
                    } else {
                        print("Failed to create GIF")
                        completion(false)
                    }
                }
            }
        }
    }

    func createGif(from images: [UIImage]) -> Data? {
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

        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("post.gif")

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

    func fixOrientation(_ image: UIImage) -> UIImage {
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
