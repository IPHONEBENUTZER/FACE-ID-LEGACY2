
import AVFoundation
import Vision
import UIKit

class FaceScanner: NSObject, ObservableObject {

    @Published var status = "Camera ready"
    @Published var faceDetected = false

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()

    func startScanning() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.status = "Camera permission denied"
                    }
                }
            }
        default:
            status = "Camera access unavailable"
        }
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            status = "Front camera not found"
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            session.beginConfiguration()

            if session.canAddInput(input) {
                session.addInput(input)
            }

            output.setSampleBufferDelegate(
                self,
                queue: DispatchQueue(label: "FaceScannerQueue")
            )

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.commitConfiguration()

            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }

            status = "Looking for a face..."
        } catch {
            status = "Camera error"
        }
    }

    func stopScanning() {
        session.stopRunning()
        status = "Scanner stopped"
        faceDetected = false
    }
}

extension FaceScanner: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer =
            CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let request = VNDetectFaceRectanglesRequest()

        do {
            try VNImageRequestHandler(
                cvPixelBuffer: imageBuffer
            ).perform([request])

            let found = !(request.results ?? []).isEmpty

            DispatchQueue.main.async {
                self.faceDetected = found
                self.status = found
                    ? "Face detected!"
                    : "Looking for a face..."
            }
        } catch {
            DispatchQueue.main.async {
                self.status = "Detection error"
            }
        }
    }
}
