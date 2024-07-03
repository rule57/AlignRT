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

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    var session: AVCaptureSession!
    var output = AVCapturePhotoOutput()

    override init() {
        super.init()
        session = AVCaptureSession()
        setupSession()
    }

    func setupSession() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

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
        let fileName = UUID().uuidString + ".jpg"
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
                self.startSession()
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
