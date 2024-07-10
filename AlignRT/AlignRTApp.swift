//
//  AlignRTApp.swift
//  AlignRT
//
//  Created by William Rule on 6/26/24.
//

import SwiftUI
import Firebase

@main
struct AlignRTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    init() {
//        FirebaseApp.configure()
//        
//        let gifCreator = GifCreator()
//        gifCreator.processAllUsers {
//            print("All user GIFs processed.")
//        }
//    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

