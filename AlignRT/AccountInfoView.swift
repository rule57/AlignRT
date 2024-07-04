
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftyGif
import MobileCoreServices
import ImageIO

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
                GifImage(gifData: profileGif) {
                    showingRetakeAlert = true
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
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
                    showingProfileCamera = true
                    capturedImages.removeAll() // Ensure capturedImages is reset
                    //profileCameraViewModel.resetSession() // Reset the camera session
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
        guard let gifData = ImageUtility.createGif(from: images) else { return }
        
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

struct GifImage: UIViewRepresentable {
    let gifData: Data
    let onTap: () -> Void

    func makeUIView(context: Context) -> UIImageView {
        let imageView = try? UIImageView(gifImage: UIImage(gifData: gifData))
        imageView?.contentMode = .scaleAspectFit
        imageView?.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        imageView?.addGestureRecognizer(tapGesture)

        return imageView ?? UIImageView()
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        do {
            let gifImage = try UIImage(gifData: gifData)
            uiView.setGifImage(gifImage)
        } catch {
            print("Error updating gif image: \(error)")
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

struct AccountInfoView_Previews: PreviewProvider {
    @State static var showingAccountInfo = true
    static var previews: some View {
        AccountInfoView(showingAccountInfo: $showingAccountInfo)
    }
}
