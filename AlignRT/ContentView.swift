
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
    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 80, height: 80)

                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 75, height: 75)

                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                // Capture photo action
                            }
                    }

                    Spacer()

                    Button(action: {
                        // Future functionality action
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 20)
            }

            VStack {
                HStack {
                    Color.black.opacity(0.5)
                        .frame(height: 50)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Color.black.opacity(0.5)
                        .frame(height: 50)
                }
            }
        }
    }
}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
