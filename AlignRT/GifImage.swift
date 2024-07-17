import SwiftUI
import SwiftyGif

struct GifImage: View {
    let gifUrl: URL
    @StateObject private var gifLoader = GifLoader()

    var body: some View {
        Group {
            if let gifData = gifLoader.gifData {
                GifImageView(gifData: gifData)
                    .onAppear {
                        print("GifImageView onAppear called")
                    }
            } else {
                ProgressView()
                    .onAppear {
                        print("ProgressView onAppear called, starting GIF load")
                        gifLoader.loadGif(from: gifUrl)
                    }
            }
        }
    }
}

struct GifImageView: UIViewRepresentable {
    let gifData: Data

    func makeUIView(context: Context) -> UIImageView {
        print("Creating UIImageView for GIF")
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        do {
            print("Setting GIF data to image view")
            let gif = try UIImage(gifData: gifData)
            uiView.setGifImage(gif, loopCount: -1)
            print("GIF image set successfully")
        } catch {
            print("Error setting gif image: \(error)")
        }
    }
}
