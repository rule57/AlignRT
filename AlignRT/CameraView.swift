//
//  CameraView.swift
//  AlignRT
//
//  Created by William Rule on 7/2/24.
//
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.viewModel = viewModel
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
