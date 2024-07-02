//
//  AccountInfoView.swift
//  AlignRT
//
//  Created by William Rule on 7/1/24.
//

import SwiftUI

struct AccountInfoView: View {
    @State private var username: String = ""
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage? = nil

    var body: some View {
        VStack {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 10)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .overlay(Text("Set Photo"))
                    .onTapGesture {
                        showingImagePicker = true
                    }
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
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }

    func saveAccountInfo() {
        // Save the username and profile picture URL to the database
        print("Username: \(username)")
        if let profileImage = profileImage {
            // Handle profile image saving
        }
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
    }
}
