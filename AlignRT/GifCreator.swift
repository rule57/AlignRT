//
//  GifCreator.swift
//  AlignRT
//
//  Created by William Rule on 7/5/24.
//
import SwiftUI
import FirebaseStorage
import SwiftyGif
import FirebaseAuth

struct GifCreatorView: View {
    @Binding var isPresented: Bool
    @State private var creatingGif = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if creatingGif {
                ProgressView("Creating GIF...")
            } else {
                Text(errorMessage ?? "Ready to create GIF")
            }
            Button(action: createGif) {
                Text("Create GIF")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear(perform: createGif)
    }

    func createGif() {
        guard let user = Auth.auth().currentUser else { return }
        creatingGif = true
        errorMessage = nil

        let storageRef = Storage.storage().reference().child("users/\(user.uid)/images")
        storageRef.listAll { (result, error) in
            if let error = error {
                errorMessage = "Error listing images: \(error.localizedDescription)"
                creatingGif = false
                return
            }

            let imageRefs = result?.items ?? []
            var images: [UIImage] = []

            let group = DispatchGroup()
            for ref in imageRefs {
                group.enter()
                ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let data = data, let image = UIImage(data: data) {
                        images.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                if images.isEmpty {
                    errorMessage = "No images found to create GIF"
                    creatingGif = false
                    return
                }

                if let gifData = Utility.createGif(from: images) {
                    let gifRef = Storage.storage().reference().child("users/\(user.uid)/profile_gif/profile.gif")
                    gifRef.putData(gifData, metadata: nil) { _, error in
                        creatingGif = false
                        if let error = error {
                            errorMessage = "Error uploading GIF: \(error.localizedDescription)"
                        } else {
                            isPresented = false
                        }
                    }
                } else {
                    errorMessage = "Error creating GIF"
                    creatingGif = false
                }
            }
        }
    }
}
