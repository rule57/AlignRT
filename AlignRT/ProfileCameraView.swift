//
//  ProfileCameraView.swift
//  AlignRT
//
//  Created by William Rule on 7/3/24.
//
//
import FirebaseAuth
import FirebaseStorage
import UniformTypeIdentifiers
import SwiftUI
import AVFoundation

struct ProfileCameraView: View {
    @Binding var capturedImages: [UIImage]
    var onComplete: ([UIImage]) -> Void
    
    @ObservedObject var viewModel = ProfileCameraViewModel()
    @State private var showFinalConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            if !showFinalConfirmation {
                ProfileCameraUIView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Spacer()

                if showFinalConfirmation {
                    VStack {
                        HStack(spacing: 20) {
                            ForEach(capturedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 10)
                                    .frame(width: 120, height: 120)
                            }
                        }
                        .padding()

                        HStack {
                            Button(action: saveProfilePhotos) {
                                Text("Save Photos")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            Button(action: retakePhotos) {
                                Text("Retake")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .padding()
                } else {
                    Button(action: {
                        withAnimation {
                            viewModel.capturePhoto()
                            provideFeedback()
                            print("photo taken")
                        }
                    }) {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.capturedImage) { _ in
            if capturedImages.count >= 3 {
                print("count reached 3")
                showFinalConfirmation = true
                viewModel.stopSession()  // Stop the camera session
            }
        }
    }

    func saveProfilePhotos() {
        onComplete(capturedImages)
        presentationMode.wrappedValue.dismiss()
    }

    func retakePhotos() {
        capturedImages.removeAll()
        showFinalConfirmation = false
        viewModel.startSession()  // Restart the camera session
    }

    func provideFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ProfileCameraUIView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ProfileCameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let previewLayer = viewModel.getPreviewLayer(for: vc.view)
        vc.view.layer.addSublayer(previewLayer)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
//
//class ProfileCameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Published var capturedImage: UIImage?
//    @Published var capturedImages: [UIImage] = []
//
//    private var session: AVCaptureSession
//    private var output: AVCapturePhotoOutput
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//
//    override init() {
//        session = AVCaptureSession()
//        output = AVCapturePhotoOutput()
//        super.init()
//
//        setupCamera()
//    }
//
//    func setupCamera() {
//        session.beginConfiguration()
//
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//              let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
//            print("Error: Unable to access the front camera")
//            return
//        }
//
//        if session.canAddInput(cameraInput) {
//            session.addInput(cameraInput)
//        }
//
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        }
//
//        session.commitConfiguration()
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
//        print("captured")
//    }
//
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else { return }
//
//        // Fix the flipping of the front camera image
//        let fixedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
//
//        DispatchQueue.main.async {
//            self.capturedImage = fixedImage
//            self.capturedImages.append(fixedImage)
//            print("image added to the array: capturedImages")
//        }
//    }
//
//    func getPreviewLayer(for view: UIView) -> AVCaptureVideoPreviewLayer {
//        if previewLayer == nil {
//            previewLayer = AVCaptureVideoPreviewLayer(session: session)
//            previewLayer?.videoGravity = .resizeAspectFill
//            previewLayer?.frame = view.bounds
//        }
//        return previewLayer!
//    }
//}
