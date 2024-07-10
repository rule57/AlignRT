import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseStorage
import Firebase
//import GTMSessionFetcherCore

struct ContentView: View {
    @State private var isAuthenticated = false

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
    @State private var creatingGif = false
    @State private var errorMessage: String?

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
                    .opacity(sliderValue)
                    .edgesIgnoringSafeArea(.all)
                    .mask(CustomMaskShape(cornerRadius: 20, blurRadius: CGFloat(12 - (sliderValue * 20)))
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all))
            }

            VStack {
                Spacer()
                Spacer()
                Spacer()
                if overlayVisible {
                    Slider(value: $sliderValue, in: 0.0...0.6, step: 0.03)
                        .padding()
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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        isButtonPressed = false
                                    }
                                    viewModel.capturePhoto()
                                    showingPreview = true
                                    print("Photo captured")
                                }
                            }
                    }
                    Spacer()
                }.padding(.bottom, 100)
            }

            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showingUserListView = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    .sheet(isPresented: $showingUserListView) {
                        UsersListView()
                    }

                    Button(action: {
                        showingAccountInfo.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    
                    Spacer()
                    
                    Button(action: {
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
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    
                    //Spacer()
                    
                    Button(action: createGif) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                }.padding(.bottom, 110)
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
        .sheet(isPresented: $showingPreview) {
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
//        .overlay(
//            VStack {
//                if creatingGif {
//                    ProgressView("Creating GIF...")
//                }
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//                Button(action: createGif) {
//                    Text("Create Post GIF")
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//                Spacer()
//            }, alignment: .bottom
//        )
    }

    func createGif() {
        guard let user = Auth.auth().currentUser else { return }
        creatingGif = true
        errorMessage = nil

        let storageRef = Storage.storage().reference().child("users/\(user.uid)/images")
        
        func listImages(retryCount: Int = 0) {
            storageRef.listAll { (result, error) in
                if let error = error {
                    if retryCount < 3 {
                        // Retry after a delay if an error occurs
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            listImages(retryCount: retryCount + 1)
                        }
                    } else {
                        errorMessage = "Too many retries, please try again later. Error: \(error.localizedDescription)"
                        creatingGif = false
                    }
                    return
                }

                guard let result = result else {
                    errorMessage = "Error: listAll result is nil"
                    creatingGif = false
                    return
                }

                let imageRefs = result.items
                var images: [UIImage] = []
                
                let group = DispatchGroup()

                func fetchImageData(ref: StorageReference) {
                    group.enter()
                    ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print("Error fetching image data: \(error.localizedDescription)")
                        } else if let data = data, let image = UIImage(data: data) {
                            images.append(image)
                        }
                        group.leave()
                    }
                }
                
                for ref in imageRefs {
                    fetchImageData(ref: ref)
                }

                group.notify(queue: .main) {
                    if images.isEmpty {
                        errorMessage = "No images found to create GIF"
                        creatingGif = false
                        return
                    }

                    if let gifData = Utility.createGif(from: images) {
                        let gifRef = Storage.storage().reference().child("users/\(user.uid)/post/post.gif")
                        gifRef.putData(gifData, metadata: nil) { _, error in
                            creatingGif = false
                            if let error = error {
                                errorMessage = "Error uploading GIF: \(error.localizedDescription)"
                            } else {
                                errorMessage = "GIF uploaded successfully"
                            }
                        }
                    } else {
                        errorMessage = "Error creating GIF"
                        creatingGif = false
                    }
                }
            }
        }
        
        listImages()
    }
}


    
//    func processGifs() {
//            guard let userId = Auth.auth().currentUser?.uid else { return }
//            isProcessingGifs = true
//            let gifCreator = GifCreator()
//            gifCreator.processAllUsers {
//                isProcessingGifs = false
//                print("All GIFs processed and uploaded.")
//            }
//        }

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

