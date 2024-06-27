//
//  CameraViewControllerWrapper.swift
//  AlignRT
//
//  Created by William Rule on 6/27/24.
//

import SwiftUI
import UIKit
import FirebaseStorage

struct CameraViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController

    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No need to update anything here for now
    }
}
