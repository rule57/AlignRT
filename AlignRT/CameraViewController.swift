import UIKit
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(imagePicker, animated: true)
    }

    private func setupImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let capturedImage = info[.originalImage] as? UIImage else {
            print("Error: Could not get the captured image")
            picker.dismiss(animated: true)
            return
        }
        uploadImageToFirebase(image: capturedImage)
        picker.dismiss(animated: true)
    }

    private func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data")
            return
        }

        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("images/\(fileName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error!.localizedDescription)")
                    return
                }
                print("Image uploaded successfully: \(downloadURL.absoluteString)")
                self.saveImageURLToDatabase(downloadURL)
            }
        }
    }

    private func saveImageURLToDatabase(_ url: URL) {
        // Add your code here to save the URL to your database
        print("Saved image URL to database: \(url.absoluteString)")
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
