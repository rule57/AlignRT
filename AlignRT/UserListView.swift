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
                            if let profileGifData = user.profileGifData {
                                ProGifImage(gifData: profileGifData) {
                                    // Optional: Add any tap action here if needed
                                }
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

                        if let postGifData = user.postGifData {
                            ProGifImage(gifData: postGifData) {
                                // Optional: Add any tap action here if needed
                            }
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

                var user = User(
                    id: document.documentID,
                    username: username,
                    profileGifData: nil,
                    postGifData: nil
                )

                fetchedUsers.append(user)
                let userId = user.id

                group.enter()
                fetchGifData(for: userId, type: .profile) { gifData in
                    if let index = fetchedUsers.firstIndex(where: { $0.id == userId }) {
                        fetchedUsers[index].profileGifData = gifData
                        print("Fetched profile GIF data for user \(userId): \(String(describing: gifData?.count)) bytes")
                    }
                    group.leave()
                }

                group.enter()
                fetchGifData(for: userId, type: .post) { gifData in
                    if let index = fetchedUsers.firstIndex(where: { $0.id == userId }) {
                        fetchedUsers[index].postGifData = gifData
                        print("Fetched post GIF data for user \(userId): \(String(describing: gifData?.count)) bytes")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.users = fetchedUsers
                for user in self.users {
                    print("User \(user.username) - Profile GIF: \(String(describing: user.profileGifData?.count)) bytes, Post GIF: \(String(describing: user.postGifData?.count)) bytes")
                }
            }
        }
    }

    enum GifType {
        case profile
        case post
    }

    func fetchGifData(for userId: String, type: GifType, completion: @escaping (Data?) -> Void) {
        let path: String
        switch type {
        case .profile:
            path = "users/\(userId)/profile_gif/profile.gif"
        case .post:
            path = "users/\(userId)/gif/\(userId).gif"
        }
        
        let storageRef = Storage.storage().reference().child(path)
        let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(userId)-\(type).gif")

        storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error loading \(type) gif for user \(userId): \(error.localizedDescription)")
                completion(nil)
            } else if let url = url {
                do {
                    let gifData = try Data(contentsOf: url)
                    completion(gifData)
                } catch {
                    print("Error reading downloaded \(type) gif for user \(userId): \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
}

struct User: Identifiable {
    var id: String
    var username: String
    var profileGifData: Data?
    var postGifData: Data?
}
