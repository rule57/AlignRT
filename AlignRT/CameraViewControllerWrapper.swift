//
//  CameraViewControllerWrapper.swift
//  AlignRT
//
//  Created by William Rule on 6/27/24.
//

import SwiftUI
import UIKit
import FirebaseStorage

//struct CameraViewControllerWrapper: UIViewControllerRepresentable {
//    typealias UIViewControllerType = CameraViewController
//
//    func makeUIViewController(context: Context) -> CameraViewController {
//        return CameraViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
//        // No need to update anything here for now
//    }
//}

//import SwiftUI


//
//
//struct CameraViewControllerWrapper: UIViewControllerRepresentable {
//    typealias UIViewControllerType = CameraViewController
//
//    @Binding var showingAccountInfo: Bool
//
//    func makeUIViewController(context: Context) -> CameraViewController {
//        let cameraViewController = CameraViewController()
//        cameraViewController.delegate = context.coordinator
//        return cameraViewController
//    }
//
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
//        // No need to update anything here for now
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: CameraViewControllerWrapper
//
//        init(_ parent: CameraViewControllerWrapper) {
//            self.parent = parent
//        }
//        
//        // Add any delegate methods if needed
//    }
//}
//
