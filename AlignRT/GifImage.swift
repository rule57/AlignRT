//
//  PlaceHolder.swift
//  AlignRT
//
//  Created by William Rule on 7/4/24.
//
import SwiftUI
import SwiftyGif

struct GifImage: UIViewRepresentable {
    let gifData: Data

    func makeUIView(context: Context) -> UIImageView {
        let imageView = try? UIImageView(gifImage: UIImage(gifData: gifData))
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        return imageView ?? UIImageView()
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        do {
            let gifImage = try UIImage(gifData: gifData)
            uiView.setGifImage(gifImage)
        } catch {
            print("Error updating gif image: \(error)")
        }
    }
}
