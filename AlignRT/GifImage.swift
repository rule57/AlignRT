//
//  PlaceHolder.swift
//  AlignRT
//
//  Created by William Rule on 7/4/24.
//
//import SwiftUI
//import SwiftyGif
//
//struct GifImage: UIViewRepresentable {
//    let gifUrl: URL
//    
//    func makeUIView(context: Context) -> UIView {
//        let container = UIView()
//        let imageView = UIImageView(gifURL: gifUrl)  // Use the gifURL initializer directly
//        
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        
//        container.addSubview(imageView)
//        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            imageView.topAnchor.constraint(equalTo: container.topAnchor),
//            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
//        ])
//        
//        return container
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let imageView = uiView.subviews.first as? UIImageView {
//            do {
//                let gif = try UIImage(gifData: Data(contentsOf: gifUrl))
//                imageView.setGifImage(gif, loopCount: -1)
//            } catch {
//                print("Error updating gif image: \(error)")
//            }
//        }
//    }
//}
import SwiftUI
import SwiftyGif

struct GifImage: UIViewRepresentable {
    let gifUrl: URL
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        container.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        loadGifAsync(for: imageView)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            loadGifAsync(for: imageView)
        }
    }
    
    private func loadGifAsync(for imageView: UIImageView) {
        URLSession.shared.dataTask(with: gifUrl) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading gif: \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                do {
                    let gif = try UIImage(gifData: data)
                    imageView.setGifImage(gif, loopCount: -1)
                } catch {
                    print("Error setting gif image: \(error)")
                }
            }
        }.resume()
    }
}
