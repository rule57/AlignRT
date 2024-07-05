//
//  ProfileCameraView.swift
//  AlignRT
//
//  Created by William Rule on 7/3/24.
//
//
//import SwiftUI
//
//import FirebaseAuth
//import FirebaseStorage
//import UniformTypeIdentifiers
//import AVFoundation
//
//struct ProfileCameraView: View {
//    @Binding var capturedImages: [UIImage]
//    var onComplete: ([UIImage]) -> Void
//
//    @ObservedObject var viewModel = ProfileCameraViewModel()
//    @State private var showFinalConfirmation = false
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        ZStack {
//            if !showFinalConfirmation {
//                ProfileCameraUIView(viewModel: viewModel)
//                    .edgesIgnoringSafeArea(.all)
//            }
//
//            VStack {
//                Spacer()
//
//                if showFinalConfirmation {
//                    VStack {
//                        HStack(spacing: 20) {
//                            ForEach(capturedImages, id: \.self) { image in
//                                Image(uiImage: image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .clipShape(Circle())
//                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                                    .shadow(radius: 10)
//                                    .frame(width: 120, height: 120)
//                            }
//                        }
//                        .padding()
//
//                        HStack {
//                            Button(action: saveProfilePhotos) {
//                                Text("Save Photos")
//                                    .padding()
//                                    .background(Color.green)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
//
//                            Button(action: retakePhotos) {
//                                Text("Retake")
//                                    .padding()
//                                    .background(Color.red)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .padding()
//                    }
//                    .background(Color.black.opacity(0.8))
//                    .cornerRadius(20)
//                    .padding()
//                } else {
//                    Button(action: {
//                        withAnimation {
//                            viewModel.capturePhoto()
//                            provideFeedback()
//                            print("Photo taken")
//                        }
//                    }) {
//                        Circle()
//                            .fill(Color.white.opacity(0.5))
//                            .frame(width: 70, height: 70)
//                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
//                    }
//                    .padding()
//                }
//            }
//        }
//        .onAppear {
//            viewModel.startSession()
//            print("Camera session started")
//        }
//        .onDisappear {
//            viewModel.stopSession()
//            print("Camera session stopped")
//        }
//        .onChange(of: viewModel.capturedImage) { _ in
//            capturedImages = viewModel.capturedImages
//            if capturedImages.count >= 3 {
//                print("Count reached 3")
//                showFinalConfirmation = true
//                viewModel.stopSession()  // Stop the camera session
//            }
//        }
//    }
//
//    func saveProfilePhotos() {
//        onComplete(capturedImages)
//        presentationMode.wrappedValue.dismiss()
//        print("Photos saved")
//    }
//
//    func retakePhotos() {
//        capturedImages.removeAll()
//        viewModel.resetCapturedImages()
//        showFinalConfirmation = false
//        viewModel.resetSession()  // Restart the camera session
//        print("Retake photos initiated")
//    }
//
//    func provideFeedback() {
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//    }
//}

//GPT DOIN SMT
import SwiftUI
import AVFoundation

struct ProfileCameraView: View {
    @Binding var capturedImages: [UIImage]
    var onComplete: ([UIImage]) -> Void

    @EnvironmentObject var viewModel: ProfileCameraViewModel
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
                            print("Photo taken")
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
//        .onChange(of: viewModel.capturedImages) { _ in
//            if capturedImages.count >= 3 {
//                print("Count reached 3")
//                showFinalConfirmation = true
//                viewModel.stopSession()
//            }
//        }
        .onChange(of: viewModel.capturedImages) { newImages in
            print("capturedImages changed, count: \(newImages.count)")
            if newImages.count >= 3 {
                print("Count reached 3")
                capturedImages = newImages
                showFinalConfirmation = true
                viewModel.stopSession()
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
        viewModel.resetSession()
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
