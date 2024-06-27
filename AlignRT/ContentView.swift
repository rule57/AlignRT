//
//  ContentView.swift
//  AlignRT
//
//  Created by William Rule on 6/26/24.
//
import SwiftUI
struct ContentView: View {
    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                RoundedRectangle(cornerRadius: 20)
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay(CameraView())
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    .background(Color.black.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    // Shutter button action
                }) {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding(.bottom, 30)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
