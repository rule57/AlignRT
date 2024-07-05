
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import SwiftyGif
import Firebase
import ImageIO
import MobileCoreServices


struct AccountInfoView: View {
    @Binding var showingAccountInfo: Bool
    @State private var username: String = ""
    @State private var showingProfileCamera = false
    @State private var capturedImages: [UIImage] = []
    @State private var profileGif: Data?
    @State private var showingRetakeAlert = false

    @StateObject var profileCameraViewModel = ProfileCameraViewModel()

    var body: some View {
        VStack {
            if let profileGif = profileGif {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(
                        ProGifImage(gifData: profileGif) {
                            showingRetakeAlert = true
                        }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 10)
                    .padding(.top, 50)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(Text("+")
                                .font(.system(size: 40))
                                .foregroundColor(.white))
                    .onTapGesture {
                        showingProfileCamera = true
                    }
                    .padding(.top, 50)
            }

            TextField("Enter username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: saveAccountInfo) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .alert(isPresented: $showingRetakeAlert) {
            Alert(
                title: Text("Retake Profile Pictures"),
                message: Text("Do you want to retake your profile pictures? This will delete the current GIF."),
                primaryButton: .destructive(Text("Retake")) {
                    deleteProfileGif()
                    capturedImages.removeAll() // Ensure capturedImages is reset
                    profileCameraViewModel.resetSession() // Reset the camera session
                    showingProfileCamera = true
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear(perform: loadAccountInfo)
        .fullScreenCover(isPresented: $showingProfileCamera) {
            ProfileCameraView(capturedImages: $capturedImages, onComplete: createAndUploadGif)
                .environmentObject(profileCameraViewModel)  // Pass the state object
        }
    }

    func saveAccountInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(["username": username], merge: true) { error in
            if let error = error {
                print("Error saving username: \(error.localizedDescription)")
            } else {
                print("Username saved successfully")
            }
        }
    }

    func loadAccountInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    self.username = data["username"] as? String ?? ""
                }
            } else {
                print("Document does not exist")
            }
        }

        loadProfileGif()
    }

    func loadProfileGif() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_gif/profile.gif")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error loading profile gif: \(error.localizedDescription)")
                return
            }
            self.profileGif = data
        }
    }

    func createAndUploadGif(images: [UIImage]) {
        guard let user = Auth.auth().currentUser else { return }
        guard let gifData = Utility.createGif(from: images) else { return }
        
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_gif/profile.gif")
        storageRef.putData(gifData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile gif: \(error.localizedDescription)")
                return
            }
            print("Profile gif uploaded successfully")
            self.profileGif = gifData
        }
    }

    func deleteProfileGif() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_gif/profile.gif")

        storageRef.delete { error in
            if let error = error {
                print("Error deleting profile gif: \(error.localizedDescription)")
            } else {
                print("Profile gif deleted successfully")
                self.profileGif = nil
            }
        }
    }
}

import SwiftUI
import SwiftyGif

struct ProGifImage: UIViewRepresentable {
    let gifData: Data
    let onTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let imageView = UIImageView()

        do {
            let gif = try UIImage(gifData: gifData)
            imageView.setGifImage(gif, loopCount: -1)
        } catch {
            print("Error creating gif image: \(error)")
        }

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        imageView.addGestureRecognizer(tapGesture)
        
        container.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            do {
                let gif = try UIImage(gifData: gifData)
                imageView.setGifImage(gif, loopCount: -1)
            } catch {
                print("Error updating gif image: \(error)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject {
        let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func handleTap() {
            onTap()
        }
    }
}
