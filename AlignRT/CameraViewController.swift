import SwiftUI
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    var capturedImage: ((UIImage?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error: Unable to initialize back camera: \(error.localizedDescription)")
            return
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput!) {
            captureSession.addOutput(photoOutput!)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
            previewLayer.frame = view.frame
            previewLayer.connection?.videoOrientation = .portrait
        }
        
        captureSession.startRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            capturedImage?(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            capturedImage?(nil)
            return
        }
        
        let image = UIImage(data: imageData)
        capturedImage?(image)
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.capturedImage = { image in
            self.capturedImage = image
        }
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    class Coordinator: NSObject {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
