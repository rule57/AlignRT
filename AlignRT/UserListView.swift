//
//  UserListView.swift
//  AlignRT
//
//  Created by William Rule on 7/5/24.
//
import SwiftUI
import Firebase
import FirebaseStorage
import SwiftyGif

struct UsersListView: View {
    @State private var users: [User] = []

    var body: some View {
        ScrollView {
            VStack {
                ForEach(users) { user in
                    VStack {
                        HStack {
                            if let profileGifUrl = user.profileGifUrl {
                                GifImage(gifUrl: profileGifUrl)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 10)
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                            }
                            Text(user.username)
                                .font(.headline)
                        }
                        .padding()

                        if let postGifUrl = user.postGifUrl {
                            GifImage(gifUrl: postGifUrl)
                                .frame(width: 300, height: 300)
                                .cornerRadius(20)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 300, height: 300)
                                .cornerRadius(20)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchUsers()
        }
    }

    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Error: documents are nil")
                return
            }

            var fetchedUsers: [User] = []
            let group = DispatchGroup()

            for document in documents {
                let data = document.data()
                let username = data["username"] as? String ?? ""
                let profileGifUrlString = data["profileGifUrl"] as? String
                let postGifUrlString = data["postGifUrl"] as? String

                var user = User(
                    id: document.documentID,
                    username: username,
                    profileGifUrl: URL(string: profileGifUrlString ?? ""),
                    postGifUrl: URL(string: postGifUrlString ?? "")
                )

                if user.postGifUrl == nil {
                    group.enter()
                    let storageRef = Storage.storage().reference().child("users/\(user.id)/post/post.gif")
                    storageRef.downloadURL { url, error in
                        if let url = url {
                            user.postGifUrl = url
                        }
                        group.leave()
                    }
                }

                fetchedUsers.append(user)
            }

            group.notify(queue: .main) {
                self.users = fetchedUsers
            }
        }
    }
}
