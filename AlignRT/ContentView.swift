import SwiftUI
import FirebaseStorage

struct ContentView: View {
    @State private var image: UIImage? = nil

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("No image available")
            }
        }
        .onAppear(perform: fetchImageFromFirebase)
    }

    func fetchImageFromFirebase() {
        let storageRef = Storage.storage().reference().child("images/YOUR_IMAGE_FILE_NAME.jpg")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            guard let imageData = data, error == nil else {
                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.image = UIImage(data: imageData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
