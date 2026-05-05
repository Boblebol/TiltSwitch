import AVFoundation
import CoreMedia
import CoreVideo
import Foundation
import QuartzCore
import Vision

final class HeadTiltMonitor: NSObject {
    enum CameraPermission {
        case authorized
        case notDetermined
        case denied
    }

    private let sessionQueue = DispatchQueue(label: "TiltSwitch.HeadTiltMonitor", qos: .userInitiated)
    private let queueKey = DispatchSpecificKey<String>()
    private let queueValue = "TiltSwitch.HeadTiltMonitor.queue"
    private let minimumVisionInterval: TimeInterval = 1.0 / 15.0

    private var session: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var lastVisionTime: TimeInterval = 0
    private var sensitivityThreshold: Double = 0.35

    var onDirection: ((Direction) -> Void)?

    override init() {
        super.init()
        sessionQueue.setSpecific(key: queueKey, value: queueValue)
    }

    static func cameraPermission() -> CameraPermission {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func start(sensitivityThreshold: Double) {
        sessionQueue.async {
            self.sensitivityThreshold = sensitivityThreshold
            guard self.session == nil else {
                return
            }

            self.configureAndStartSession()
        }
    }

    func updateSensitivityThreshold(_ threshold: Double) {
        sessionQueue.async {
            self.sensitivityThreshold = threshold
        }
    }

    func stop() {
        if DispatchQueue.getSpecific(key: queueKey) == queueValue {
            teardownSession()
        } else {
            sessionQueue.sync {
                teardownSession()
            }
        }
    }

    private func configureAndStartSession() {
        guard Self.cameraPermission() == .authorized else {
            return
        }

        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .low

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else {
            captureSession.commitConfiguration()
            return
        }

        captureSession.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        output.setSampleBufferDelegate(self, queue: sessionQueue)

        guard captureSession.canAddOutput(output) else {
            captureSession.commitConfiguration()
            return
        }

        captureSession.addOutput(output)
        captureSession.commitConfiguration()

        videoOutput = output
        session = captureSession
        captureSession.startRunning()
    }

    private func teardownSession() {
        guard let session else {
            return
        }

        videoOutput?.setSampleBufferDelegate(nil, queue: nil)
        if session.isRunning {
            session.stopRunning()
        }
        for input in session.inputs {
            session.removeInput(input)
        }
        for output in session.outputs {
            session.removeOutput(output)
        }
        videoOutput = nil
        self.session = nil
        lastVisionTime = 0
    }

    private func process(sampleBuffer: CMSampleBuffer) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastVisionTime >= minimumVisionInterval else {
            return
        }

        lastVisionTime = currentTime

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )

        do {
            try handler.perform([request])
        } catch {
            return
        }

        guard let roll = request.results?.first?.roll?.doubleValue else {
            return
        }

        let threshold = sensitivityThreshold
        let direction: Direction?
        if roll > threshold {
            direction = .right
        } else if roll < -threshold {
            direction = .left
        } else {
            direction = nil
        }

        guard let direction else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.onDirection?(direction)
        }
    }
}

extension HeadTiltMonitor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        process(sampleBuffer: sampleBuffer)
    }
}
