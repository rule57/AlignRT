//
//  ProfileCameraView.swift
//  AlignRT
//
//  Created by William Rule on 7/3/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct ProfileCameraView: View {
    @ObservedObject var viewModel = ProfileCameraViewModel()
    @State private var showingPreview = false
    @State private var showUseRetakePrompt = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            ProfileCameraUIView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                if !showUseRetakePrompt {
                    Button(action: {
                        withAnimation {
                            viewModel.capturePhoto()
                        }
                    }) {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    }
                    .padding()
                } else {
                    HStack {
                        Button(action: {
                            if viewModel.capturedImages.count >= 3 {
                                saveProfilePhotos()
                            } else {
                                withAnimation {
                                    showUseRetakePrompt = false
                                }
                            }
                        }) {
                            Text("Use Photo")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            viewModel.capturedImages.removeLast()
                            withAnimation {
                                showUseRetakePrompt = false
                            }
                        }) {
                            Text("Retake")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }

            if showingPreview, let capturedImage = viewModel.capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .background(Color.black.opacity(0.5))
                    .onTapGesture {
                        withAnimation {
                            showingPreview = false
                            showUseRetakePrompt = true
                        }
                    }
            }
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onReceive(viewModel.$capturedImage) { image in
            if let _ = image {
                showingPreview = true
            }
        }
    }

    func saveProfilePhotos() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_pics")

        for (index, photo) in viewModel.capturedImages.enumerated() {
            if let imageData = photo.jpegData(compressionQuality: 0.8) {
                let photoRef = storageRef.child("\(UUID().uuidString).jpg")
                photoRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading photo \(index): \(error.localizedDescription)")
                    } else {
                        print("Photo \(index) uploaded successfully to path: \(photoRef.fullPath)")
                    }
                }
            }
        }

        viewModel.capturedImages.removeAll()
        presentationMode.wrappedValue.dismiss()
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