import Foundation

class GifLoaderManager {
    static let shared = GifLoaderManager()
    private var loadingTasks: [URL: URLSessionDataTask] = [:]
    private let semaphore = DispatchSemaphore(value: 1)

    private init() {}

    func loadGif(from url: URL, completion: @escaping (Data?) -> Void) {
        semaphore.wait()

        if let existingTask = loadingTasks[url] {
            print("GIF load already in progress for URL: \(url)")
            semaphore.signal()
            return
        }

        print("Starting to load GIF from URL: \(url)")
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.loadingTasks[url] = nil
                self?.semaphore.signal()
            }

            if let error = error {
                print("Error loading gif: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received for gif")
                completion(nil)
                return
            }

            print("GIF data loaded successfully")
            completion(data)
        }
        
        loadingTasks[url] = dataTask
        dataTask.resume()
    }
}
