//
//  UserListView.swift
//  AlignRT
//
//  Created by William Rule on 7/5/24.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct UsersListView: View {
    @State private var users: [User] = []
    @State private var profileGifUrls: [String: String] = [:]
    
    var body: some View {
        VStack {
            List(users) { user in
                HStack {
                    if let urlString = profileGifUrls[user.id ?? ""], let url = URL(string: urlString) {
                        GifImageView(gifUrl: url)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    Text(user.username)
                }
            }
            .onAppear {
                fetchUsers()
            }
        }
    }
    
    private func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                self.users = snapshot.documents.compactMap { doc -> User? in
                    try? doc.data(as: User.self)
                }
                fetchProfileGifs()
            }
        }
    }
    
    private func fetchProfileGifs() {
        let storage = Storage.storage()
        
        for user in users {
            guard let userId = user.id else { continue }
            let gifRef = storage.reference().child("users/\(userId)/profile_gif/profile.gif")
            gifRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching profile gif URL: \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    DispatchQueue.main.async {
                        self.profileGifUrls[userId] = url.absoluteString
                    }
                }
            }
        }
    }
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView()
    }
}
