//
//  GifImageView.swift
//  AlignRT
//
//  Created by William Rule on 7/5/24.
//
import SwiftUI
import SwiftyGif

struct GifImageView: UIViewRepresentable {
    let gifUrl: URL
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setGifFromURL(gifUrl)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.setGifFromURL(gifUrl)
    }
}
