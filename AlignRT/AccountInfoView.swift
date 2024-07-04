//
//  AccountInfoView.swift
//  AlignRT
//
//  Created by William Rule on 7/1/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct AccountInfoView: View {
    @Binding var showingAccountInfo: Bool
    @State private var username: String = ""
    @State private var showingProfileCamera = false
    @State private var profileImages: [UIImage] = []
    @State private var currentImageIndex = 0
    @GestureState private var dragOffset = CGSize.zero
    @State private var timer: Timer?
    @State private var showingRetakeAlert = false

    var body: some View {
        VStack {
            if !profileImages.isEmpty {
                Image(uiImage: profileImages[currentImageIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 10)
                    .padding(.top, 50)
                    .onTapGesture {
                        showingRetakeAlert = true
                    }
                    .onAppear(perform: startImageSwitching)
                    .onDisappear(perform: stopImageSwitching)
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
        .offset(y: dragOffset.height)
        .gesture(
            DragGesture().updating($dragOffset) { drag, state, _ in
                state = drag.translation
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    withAnimation {
                        showingAccountInfo = false
                    }
                }
            }
        )
        .alert(isPresented: $showingRetakeAlert) {
            Alert(
                title: Text("Retake Profile Pictures"),
                message: Text("Do you want to retake your profile pictures? This will delete the current pictures."),
                primaryButton: .destructive(Text("Retake")) {
                    deleteProfilePics()
                    showingProfileCamera = true
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear(perform: loadAccountInfo)
        .fullScreenCover(isPresented: $showingProfileCamera) {
            ProfileCameraView()
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

        loadProfileImages()
    }

    func loadProfileImages() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_pics")
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing profile pics: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("No result found")
                return
            }

            for item in result.items {
                item.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error downloading profile pic: \(error.localizedDescription)")
                        return
                    }

                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImages.append(image)
                        }
                    }
                }
            }
        }
    }

    func startImageSwitching() {
        stopImageSwitching()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation {
                currentImageIndex = (currentImageIndex + 1) % profileImages.count
            }
        }
    }

    func stopImageSwitching() {
        timer?.invalidate()
        timer = nil
    }

    func deleteProfilePics() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("users/\(user.uid)/profile_pics")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing profile pics: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("No result found")
                return
            }

            for item in result.items {
                item.delete { error in
                    if let error = error {
                        print("Error deleting profile pic: \(error.localizedDescription)")
                    } else {
                        print("Profile pic deleted successfully")
                    }
                }
            }

            // Clear local profile images
            self.profileImages.removeAll()
        }
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    @State static var showingAccountInfo = true
    static var previews: some View {
        AccountInfoView(showingAccountInfo: $showingAccountInfo)
    }
}
