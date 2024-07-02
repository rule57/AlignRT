//
//  PhotoPreviewViewController.swift
//  AlignRT
//
//  Created by William Rule on 7/1/24.
//

import UIKit

class PhotoPreviewViewController: UIViewController {
    var image: UIImage?
    var onSave: (() -> Void)?
    var onRetake: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)

        let retakeButton = UIButton(type: .system)
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [saveButton, retakeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.frame = CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 50)
        view.addSubview(stackView)
    }

    @objc func savePhoto() {
        dismiss(animated: true) {
            self.onSave?()
        }
    }

    @objc func retakePhoto() {
        dismiss(animated: true) {
            self.onRetake?()
        }
    }
}
