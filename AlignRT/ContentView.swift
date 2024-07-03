
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit


struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showingAccountInfo = false
    
    var body: some View {
        VStack {
            if isAuthenticated {
                CameraViewWrapper()
                    .edgesIgnoringSafeArea(.all)
            } else {
                SignInWithAppleView(isAuthenticated: $isAuthenticated)
                
            }
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                isAuthenticated = true
            }
        }
    }
}
struct CameraViewWrapper: View {
    @StateObject var viewModel = CameraViewModel()
    @State private var isButtonPressed = false
    @State private var showingPreview = false
    
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
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
                                    viewModel.capturePhoto()
                                    showingPreview = true
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
        .sheet(isPresented: $showingPreview) {  //The presentation of this needs to change
            if let capturedImage = viewModel.capturedImage {
                PhotoPreviewView(image: capturedImage, onSave: {
                    viewModel.savePhoto(capturedImage)
                    showingPreview = false
                }, onRetake: {
                    showingPreview = false
                    viewModel.startSession()
                })
            }
        }
        
    }
}


struct PhotoPreviewView: View {
    var image: UIImage
    var onSave: () -> Void
    var onRetake: () -> Void
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: onSave) {
                    Text("Save")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: onRetake) {
                    Text("Retake")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

