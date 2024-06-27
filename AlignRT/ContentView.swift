//
//  ContentView.swift
//  AlignRT
//
//  Created by William Rule on 6/26/24.
//
import SwiftUI
struct ContentView: View {
    @State private var capturedImage: UIImage? = nil
    @State private var showCapturedImage: Bool = false
    
    var body: some View {
        ZStack {
            CameraView(capturedImage: $capturedImage)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .aspectRatio(4/3, contentMode: .fit)
                        .foregroundColor(.clear)
                        .background(Color.black)
                        .blendMode(.destinationOut)
                        .padding()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                        .aspectRatio(4/3, contentMode: .fit)
                        .padding()
                }
                .compositingGroup()
                
                Spacer()
                
                Button(action: {
                    let cameraController = CameraViewController()
                    cameraController.capturePhoto()
                    showCapturedImage.toggle()
                }) {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showCapturedImage) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No image captured")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
