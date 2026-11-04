//
//  VideoCapture.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import AVFoundation
import CoreImage
import Synchronization

/// A camera session that renders frames synchronously before returning capture buffers.
actor VideoCapture : NSObject {
    
    let camera: Camera
    unowned let manager: VideoCaptureManager
    
    private var session = Session()
    private let bufferingQueue: DispatchQueue

    /// Observers shared between the actor and the serial capture callback queue.
    private nonisolated let observerStorage = Mutex<[VideoCaptureObserver]>([])

    /// The rendering context reused on this camera's serial callback queue.
    private nonisolated let imageContext = CIContext(options: [.cacheIntermediates: false])

    /// A snapshot of the current observers; callbacks run without holding the storage lock.
    var observers: [VideoCaptureObserver] {
        observerStorage.withLock { $0 }
    }
    
    /// Create and start a session that drops late frames instead of accumulating capture buffers.
    /// - Parameters:
    ///   - camera: The camera supplying the video.
    ///   - manager: The owner of this capture session.
    /// - Throws: An input creation or session configuration error.
    init(camera: Camera, manager: VideoCaptureManager) throws {
        
        let input = try AVCaptureDeviceInput(device: camera.device)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true

        self.camera = camera
        self.manager = manager

        try session.addInput(input)
        try session.addOutput(output)

        bufferingQueue = DispatchQueue(label: "Video Capture Buffer for \(camera)")
        
        super.init()
        
        output.setSampleBufferDelegate(self, queue: bufferingQueue)

        session.startRunning()
    }
    
    deinit {
        
        session.stopRunning()
    }
    
    var preset: AVCaptureSession.Preset {
    
        get {
            
            session.preset
        }
        
        set {
            
            session.preset = newValue
        }
    }
    
    /// Register an observer for subsequent frames, ignoring duplicate registrations.
    func addVideoCaptureObserver(_ observer: VideoCaptureObserver) async {
        observerStorage.withLock { observers in
            guard !observers.contains(observer) else {
                return
            }
            observers.append(observer)
        }
    }
    
    /// Remove an observer; a callback already using a snapshot may still finish.
    func removeVideoCaptureObserver(_ observer: VideoCaptureObserver) async {
        observerStorage.withLock { observers in
            observers.removeAll { $0 === observer }
        }
    }
}

private extension VideoCapture {
    
    struct Session : @unchecked Sendable {
        
        private let rawSession = AVCaptureSession()
    }
}

/// Synchronous frame rendering and delivery on the session's serial callback queue.
extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate {

    /// Render one independent image and deliver it without retaining the sample buffer in a task.
    ///
    /// Slow rendering is bounded by `alwaysDiscardsLateVideoFrames`. Observers must return
    /// promptly and bound any image queue they maintain for asynchronous display.
    nonisolated
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            let observers = observerStorage.withLock { $0 }
            guard !observers.isEmpty, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            let image = CIImage(cvPixelBuffer: imageBuffer)
            guard let renderedImage = imageContext.createCGImage(image, from: image.extent, format: .RGBA8, colorSpace: image.colorSpace, deferred: false) else {
                return
            }
            for observer in observers {
                observer.videoCapture(self, didOutput: renderedImage)
            }
        }
    }
}

extension VideoCapture.Session {
    
    var preset: AVCaptureSession.Preset {
    
        get {
            
            rawSession.sessionPreset
        }
        
        set {
            
            rawSession.sessionPreset = newValue
        }
    }
    
    func addInput(_ input: AVCaptureDeviceInput) throws {
        
        guard rawSession.canAddInput(input) else {
            
            throw VideoCaptureError.cameraNotAcceptable(name: input.device.localizedName, id: input.device.uniqueID)
        }
        
        rawSession.addInput(input)
    }
    
    func addOutput(_ output: AVCaptureOutput) throws {
        
        guard rawSession.canAddOutput(output) else {
            
            throw VideoCaptureError.internalError("Failed to prepare output.")
        }
        
        rawSession.addOutput(output)
    }
    
    func startRunning() {
        
        rawSession.startRunning()
    }
    
    func stopRunning() {
        
        rawSession.stopRunning()
    }
}

extension Sequence where Element == VideoCapture {
    
    func videoCapture(havingCamera camera: Camera) -> Element? {
        
        first { $0.camera == camera }
    }
    
    func contains(camera: Camera) -> Bool {
        
        map(\.camera).contains(camera)
    }
}
