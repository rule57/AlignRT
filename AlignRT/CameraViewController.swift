//
//import UIKit
//import FirebaseStorage
//
//class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    var imagePicker: UIImagePickerController!
//    var delegate: CameraViewControllerWrapper.Coordinator?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupImagePicker()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        present(imagePicker, animated: true)
//    }
//
//    private func setupImagePicker() {
//        imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        imagePicker.allowsEditing = false
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        guard let capturedImage = info[.originalImage] as? UIImage else {
//            print("Error: Could not get the captured image")
//            picker.dismiss(animated: true)
//            return
//        }
//        uploadImageToFirebase(image: capturedImage)
//        picker.dismiss(animated: true)
//    }
//
//    private func uploadImageToFirebase(image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            print("Error: Could not convert image to data")
//            return
//        }
//
//        let fileName = UUID().uuidString + ".jpg"
//        let storageRef = Storage.storage().reference().child("images/\(fileName)")
//        
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            guard error == nil else {
//                print("Error uploading image: \(error!.localizedDescription)")
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                guard let downloadURL = url else {
//                    print("Error getting download URL: \(error!.localizedDescription)")
//                    return
//                }
//                print("Image uploaded successfully: \(downloadURL.absoluteString)")
//                self.saveImageURLToDatabase(downloadURL)
//            }
//        }
//    }
//
//    private func saveImageURLToDatabase(_ url: URL) {
//        // Add your code here to save the URL to your database
//        print("Saved image URL to database: \(url.absoluteString)")
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true)
//    }
//}
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var viewModel: CameraViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startSession()
        setupPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSession()
    }

    func setupPreview() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
    }
}
//import UIKit
//import AVFoundation
//import FirebaseStorage
//import SwiftUI
//
//class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
//    var session: AVCaptureSession!
//    var output = AVCapturePhotoOutput()
//    var previewLayer: AVCaptureVideoPreviewLayer!
//    var capturedImage: UIImage?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        session = AVCaptureSession()
//        setupSession()
//        setupPreview()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        startSession()
//    }
//
//    func setupSession() {
//        session.beginConfiguration()
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//              let input = try? AVCaptureDeviceInput(device: device) else {
//            return
//        }
//
//        if session.canAddInput(input) {
//            session.addInput(input)
//        }
//
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        }
//
//        session.commitConfiguration()
//    }
//
//    func setupPreview() {
//        previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.bounds
//    }
//
//    func startSession() {
//        if !session.isRunning {
//            session.startRunning()
//        }
//    }
//
//    func stopSession() {
//        if session.isRunning {
//            session.stopRunning()
//        }
//    }
//
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//        output.capturePhoto(with: settings, delegate: self)
//    }
//
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData) else { return }
//        capturedImage = image
//        // Handle showing the captured photo
//        showCapturedPhoto(image)
//    }
//
//    func showCapturedPhoto(_ image: UIImage) {
//        let photoPreviewVC = PhotoPreviewViewController()
//        photoPreviewVC.image = image
//        photoPreviewVC.onSave = { [weak self] in
//            self?.savePhoto(image)
//        }
//        photoPreviewVC.onRetake = { [weak self] in
//            self?.startSession()
//        }
//        stopSession()
//        present(photoPreviewVC, animated: true, completion: nil)
//    }
//
//    func savePhoto(_ image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//        let fileName = UUID().uuidString + ".jpg"
//        let storageRef = Storage.storage().reference().child("images/\(fileName)")
//        
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            guard error == nil else {
//                print("Error uploading image: \(error!.localizedDescription)")
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                guard let downloadURL = url else {
//                    print("Error getting download URL: \(error!.localizedDescription)")
//                    return
//                }
//                print("Image uploaded successfully: \(downloadURL.absoluteString)")
//                self.startSession()
//            }
//        }
//    }
//}
//
//
//struct CameraView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = CameraViewController
//
//    func makeUIViewController(context: Context) -> CameraViewController {
//        let vc = CameraViewController()
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
//
//    static func dismantleUIViewController(_ uiViewController: CameraViewController, coordinator: ()) {
//        uiViewController.stopSession()
//    }
//}
