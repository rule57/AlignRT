import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        VStack {
            if isAuthenticated {
                CameraViewControllerWrapper()
                    .edgesIgnoringSafeArea(.all)
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}

struct LoginView: View {  //Replace this with SignInWithAppleView()
    @State private var email = ""
    @State private var password = ""
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            CameraViewControllerWrapper()
            //SignInWithAppleView()
        }
        .padding()
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                isAuthenticated = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
