
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit


struct ContentView: View {
    @State private var isAuthenticated = false
    @StateObject var gifCreator = GifCreator()
    
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
    @State private var overlayVisible = false
    @State private var lastImage: UIImage?
    @State private var sliderValue: Double = 0.3
    @State private var showingAccountInfo = false
    @State private var showingUserListView = false
    @StateObject var gifCreator = GifCreator()
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            Image("CameraPreviewBackground1")
                .resizable()
                .opacity(0.6)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            if overlayVisible, let lastImage = lastImage {
                Image(uiImage: lastImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .opacity(sliderValue) // Use slider value for opacity
                    //.blur(radius: CGFloat(sliderValue * 10)) // Scale slider value for blur
                    .edgesIgnoringSafeArea(.all)
                    .mask(CustomMaskShape(cornerRadius: 20, blurRadius: CGFloat(12 - (sliderValue * 20))) // Pass scaled blur value
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all))
            }
            VStack{
                Spacer()
                Spacer()
                Spacer()
                if overlayVisible {
                    Slider(value: $sliderValue, in: 0.0...0.6, step: 0.03)
                        .padding()
    //                    .background(Color.white.opacity(0.5))
    //                    .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .tint(.white)
                }
            }
            
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
                                    overlayVisible = false
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
                    Spacer()
                }.padding(.bottom, 100)
                
                
            }
            
            VStack{
                Spacer()
                HStack{
                    Button(action: { //FEED BUTTON
                        showingUserListView = true
                    }){
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)}
                    
                    .sheet(isPresented: $showingUserListView) {
                                        UsersListView()
                                    }
                    Button(action: { //Account Button!!!
                        showingAccountInfo.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    //Spacer()   //EXTRA
                    
                    Spacer()
                    
                    Button(action: { //Overlay Button!!!
                        if overlayVisible {
                            withAnimation {
                                overlayVisible = false
                            }
                        } else {
                            viewModel.fetchLastImageURL { url in
                                guard let url = url else { return }
                                viewModel.fetchImage(from: url) { image in
                                    if let image = image {
                                        self.lastImage = image
                                        withAnimation {
                                            overlayVisible = true
                                        }
                                    }
                                }
                            }
                        }
                    
                        // Future functionality action
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
//                    Button(action: {
//                        if let user = Auth.auth().currentUser {
//                            gifCreator.createAndUploadGif(for: user.uid) { success in
//                                if success {
//                                    print("Post GIF created and uploaded successfully")
//                                } else {
//                                    print("Failed to create and upload post GIF")
//                                }
//                            }
//                        }
//                    }) {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.5))
//                            .clipShape(Circle())
//                            .frame(width: 60, height: 60)
//                    }
                    
                }.padding(.bottom, 110)
                // Adjust bottom padding to position the buttons
            }
            if showingAccountInfo {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 10)
                    .transition(.move(edge: .bottom))
                AccountInfoView(showingAccountInfo: $showingAccountInfo)
                    .transition(.move(edge: .bottom))
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
struct CustomMaskShape: View {
    var cornerRadius: CGFloat
    var blurRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let maskRect = CGRect(x: geometry.size.width / 19, // Adjust width and height
                                  y: geometry.size.height / 5,
                                  width: geometry.size.height / 2.5,
                                  height: geometry.size.height / 2.2)
            
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: maskRect.width, height: maskRect.height)
                    .offset(x: maskRect.minX, y: maskRect.minY)
                    .blur(radius: blurRadius) // Adjust blur radius as needed
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

