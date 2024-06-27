import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("No image available")
            }
        }
        .onAppear(perform: fetchImageFromFirebase)
    }

    func fetchImageFromFirebase() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User is not authenticated"
            return
        }

        let storageRef = Storage.storage().reference().child("images/YOUR_IMAGE_FILE_NAME.jpg")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                // Handle specific error codes related to no object found
                if let errorCode = (error as NSError?)?.code, errorCode == StorageErrorCode.objectNotFound.rawValue {
                    DispatchQueue.main.async {
                        self.errorMessage = "No image found for the user."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error fetching image: \(error.localizedDescription)"
                    }
                }
                return
            }

            guard let imageData = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: Image data is nil"
                }
                return
            }

            DispatchQueue.main.async {
                self.image = UIImage(data: imageData)
                self.errorMessage = nil
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
