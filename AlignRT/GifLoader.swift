import Foundation
import SwiftyGif

class GifLoader: ObservableObject {
    @Published var gifData: Data?

    func loadGif(from url: URL) {
        GifLoaderManager.shared.loadGif(from: url) { data in
            DispatchQueue.main.async {
                self.gifData = data
            }
        }
    }
}
