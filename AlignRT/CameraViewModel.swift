//
//  CameraViewModel.swift
//  AlignRT
//
//  Created by William Rule on 7/2/24.
//
import SwiftUI
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    @Published var capturedImages: [UIImage] = []
    @Published var lastCapturedImage: UIImage?
    
    var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var output = AVCapturePhotoOutput()
    let db = Firestore.firestore()

    override init() {
        super.init()
        session = AVCaptureSession()
        setupSession()
    }

    func setupSession() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func savePhoto(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let userID = user.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(timestamp)_\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("users/\(userID)/images/\(fileName)")

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
                self.storeImageURL(downloadURL.absoluteString)
                self.startSession()
            }
        }
    }

    func storeImageURL(_ url: String) {
        guard let user = Auth.auth().currentUser else { return }
        let userID = user.uid
        db.collection("users").document(userID).setData(["lastImageURL": url], merge: true) { error in
            if let error = error {
                print("Error storing image URL: \(error)")
            } else {
                print("Image URL stored successfully")
            }
        }
    }

    func fetchLastImageURL(completion: @escaping (String?) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let userID = user.uid
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let url = document.data()?["lastImageURL"] as? String
                completion(url)
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }

    func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image data: \(error)")
                completion(nil)
            } else if let data = data {
                completion(UIImage(data: data))
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        DispatchQueue.main.async {
            self.lastCapturedImage = self.capturedImage
            self.capturedImage = image
        }
    }
    





    func setupCamera(isFrontCamera: Bool = false) {
        session.beginConfiguration()

        let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: isFrontCamera ? .front : .back)
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera!) else { return }

        if session.canAddInput(cameraInput) {
            session.addInput(cameraInput)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }


    func getPreviewLayer(for view: UIView) -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
        }
        return previewLayer!
    }
}
