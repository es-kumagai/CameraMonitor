//
//  VideoCapture.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import AVFoundation

actor VideoCapture : NSObject {
    
    let camera: Camera
    
    private var session = Session()
    private let bufferingQueue: DispatchQueue

    private(set) var observers: [VideoCaptureObserver] = []
    
    init(camera: Camera) throws {
        
        let input = try AVCaptureDeviceInput(device: camera.device)
        let output = AVCaptureVideoDataOutput()

        self.camera = camera

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
    
    func addVideoCaptureObserver(_ observer: VideoCaptureObserver) async {

        guard !observers.map(\.videoCaptureObserverIdentifier).contains(observer.videoCaptureObserverIdentifier) else {
            
            return
        }
        
        observers.append(observer)
    }
}

private extension VideoCapture {
    
    struct Session : @unchecked Sendable {
        
        private let rawSession = AVCaptureSession()
    }
}

extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate {

    nonisolated
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task.detached {
            
            let observers = await self.observers
            
            for observer in observers {
                
                observer.videoCapture(self, didOutput: sampleBuffer.instance)
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
        
        first { $0 == camera }
    }
    
    func contains(camera: Camera) -> Bool {
        
        map(\.camera).contains(camera)
    }
    
    func videoCapturesDidRelease() async {

        for videoCapture in self {

            for observer in await videoCapture.observers {
                
                observer.videoCaptureDidRelease(videoCapture)
            }
        }
    }
}
