//
//  AccountInfoView.swift
//  AlignRT
//
//  Created by William Rule on 7/1/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AccountInfoView: View {
    @Binding var showingAccountInfo: Bool
    @State private var username: String = ""
    @State private var showingProfileCamera = false
    @State private var profileImage: UIImage? = nil
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        VStack {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
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
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    @State static var showingAccountInfo = true
    static var previews: some View {
        AccountInfoView(showingAccountInfo: $showingAccountInfo)
    }
}
