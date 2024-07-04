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
    @State private var showFinalConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            ProfileCameraUIView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                if showFinalConfirmation {
                    VStack {
                        HStack(spacing: 20) {
                            ForEach(viewModel.capturedImages, id: \.self) { image in
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
        .onReceive(viewModel.$capturedImage) { image in
            if viewModel.capturedImages.count >= 3 {
                showFinalConfirmation = true
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

    func retakePhotos() {
        viewModel.capturedImages.removeAll()
        showFinalConfirmation = false
    }

    func provideFeedback() {
        // Implement feedback mechanism, e.g., flash screen or vibrate
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
