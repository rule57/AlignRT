//
//  CameraView.swift
//  AlignRT
//
//  Created by William Rule on 6/26/24.
//

import SwiftUI
import AVFoundation
import FirebaseStorage

struct CameraView2: View {
    @StateObject var camera = CameraModel()

    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)

            VStack {
                Spacer()

                if camera.isTaken {
                    VStack {
                        Image(uiImage: camera.previewImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        HStack {
                            Button(action: camera.retakePicture) {
                                Text("Retake")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            Button(action: camera.savePicture) {
                                Text("Save")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                } else {
                    Button(action: camera.takePicture) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    private var output = AVCapturePhotoOutput()
    private var previewLayer = AVCaptureVideoPreviewLayer()
    @Published var isTaken = false
    @Published var previewImage: UIImage?

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupSession()
                }
            }
        default:
            // Handle denied permissions
            break
        }
    }

    func setupSession() {
        do {
            session.beginConfiguration()

            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try AVCaptureDeviceInput(device: device!)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill

            session.commitConfiguration()
            session.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    func takePicture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func retakePicture() {
        self.isTaken = false
        self.previewImage = nil
    }

    func savePicture() {
        guard let image = previewImage else { return }

        let storage = Storage.storage().reference()
        let imageName = UUID().uuidString
        let imageRef = storage.child("images/\(imageName).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                } else {
                    print("Image uploaded successfully")
                    self.retakePicture()
                }
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let imageData = photo.fileDataRepresentation() else { return }
        self.previewImage = UIImage(data: imageData)
        self.isTaken = true
    }
}

//extension CameraModel: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation() else { return }
//        self.previewImage = UIImage(data: imageData)
//        self.isTaken = true
//    }
//}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = camera.session
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
