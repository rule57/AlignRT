
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var viewModel: CameraViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startSession()
        setupPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSession()
    }

    func setupPreview() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
    }
}
