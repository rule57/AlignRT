//
//  ProfileCameraViewModel.swift
//  AlignRT
//
//  Created by William Rule on 7/3/24.
//
import SwiftUI
import AVFoundation


class ProfileCameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    @Published var capturedImages: [UIImage] = []

    private var session: AVCaptureSession
    private var output: AVCapturePhotoOutput
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        session = AVCaptureSession()
        output = AVCapturePhotoOutput()
        super.init()

        setupCamera()
    }

    func setupCamera() {
        session.beginConfiguration()

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            print("Error: Unable to access the front camera")
            return
        }

        if session.canAddInput(cameraInput) {
            session.addInput(cameraInput)
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
        print("captured")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }

        // Fix the flipping of the front camera image
        let fixedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)

        DispatchQueue.main.async {
            self.capturedImage = fixedImage
            self.capturedImages.append(fixedImage)
            print("image added to the array: capturedImages")
        }
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
