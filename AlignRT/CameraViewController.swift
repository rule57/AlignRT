import UIKit
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let capturedImage = info[.originalImage] as? UIImage {
            uploadImageToFirebase(image: capturedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data")
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                return
            }

            storageRef.downloadURL { [weak self] (url, error) in
                guard let self = self else { return }
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error!.localizedDescription)")
                    return
                }
                print("Image uploaded successfully: \(downloadURL.absoluteString)")
                // Save the URL or perform any other necessary actions
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
