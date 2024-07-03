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

    var body: some View {
        ZStack {
            ProfileCameraUIView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                HStack {
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

                    Button(action: savePhotos) {
                        Text("Save Photos")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
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
                        }
                    }
            }
        }
        .onAppear {
            viewModel.setupCamera()
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

    func savePhotos() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("profile_photos/\(user.uid)")

        for (index, photo) in viewModel.capturedImages.enumerated() {
            if let imageData = photo.jpegData(compressionQuality: 0.8) {
                let photoRef = storageRef.child("\(UUID().uuidString).jpg")
                photoRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading photo \(index): \(error.localizedDescription)")
                    } else {
                        print("Photo \(index) uploaded successfully")
                    }
                }
            }
        }
    }
}

struct ProfileCameraUIView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ProfileCameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        viewModel.getPreviewLayer(for: vc.view)
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
