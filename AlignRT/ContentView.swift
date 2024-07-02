
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
//
//struct ContentView: View {
//    @State private var isAuthenticated = false
//    @State private var showingAccountInfo = false
//
//    var body: some View {
//        VStack {
//            if isAuthenticated {
//                ZStack {
//                    CameraViewControllerWrapper(showingAccountInfo: $showingAccountInfo)
//                        .edgesIgnoringSafeArea(.all)
//
//                    VStack {
//                        Spacer()
//                        Button(action: {
//                            showingAccountInfo = true
//                        }) {
//                            Text("Account Information")
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        .padding(.bottom, 50)
//                    }
//                }
//                .sheet(isPresented: $showingAccountInfo) {
//                    AccountInfoView()
//                }
//            } else {
//                SignInWithAppleView(isAuthenticated: $isAuthenticated)
//            }
//        }
//    }
//}
//import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showingAccountInfo = false
    
    var body: some View {
        VStack {
            if isAuthenticated {
                CameraViewWrapper()
                    .edgesIgnoringSafeArea(.all)
            } else {
                //                SignInWithAppleView(isAuthenticated: $isAuthenticated)
                CameraViewWrapper()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
struct CameraViewWrapper: View {
    @State private var isButtonPressed = false

    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)

            Image("CameraPreviewBackground1")
                .resizable()
                .opacity(0.6)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(isButtonPressed ? Color.white.opacity(0.1) : Color.white.opacity(0.3))
                            .frame(width: 90, height: 90)
                            .animation(.easeInOut(duration: 0.1), value: isButtonPressed)

                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 85, height: 85)
                            .scaleEffect(isButtonPressed ? 0.9 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isButtonPressed)

                        Circle()
                            .fill(isButtonPressed ? Color.white.opacity(0.3) : Color.white.opacity(0.5))
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                withAnimation {
                                    isButtonPressed = true
                                }
                                // Simulate a short delay for the button press visual feedback
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        isButtonPressed = false
                                    }
                                    // Capture photo action
                                    //capturePhoto()
                                    print("Photo captured")
                                }
                            }
                    }
                    
                    Spacer()// Adjust spacing as needed

                }.padding(.bottom, 100)
                
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Button(action: {
                        // Future functionality action
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    Spacer()
                }.padding(.bottom, 110)
                 // Adjust bottom padding to position the buttons
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

