//
//  CameraView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

@preconcurrency import AppKit
import AVFoundation

@objc(ESCameraView)
@MainActor
final class CameraView : NSView {
    
    @IBOutlet weak var delegate: CameraViewDelegate?

    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var expandButton: NSButton!
    @IBOutlet var contentView: CameraPreviewView!
    @IBOutlet var captureImageView: NSImageView!

    private var videoCapture: VideoCapture?
    private var cameraObserver: CameraObserver!
    
    private var currentCaptureImage: NSImage? {
        
        didSet {

            guard let currentCaptureImage = currentCaptureImage else {
                
                return
            }

            captureImageView?.image = currentCaptureImage
        }
    }
    
    dynamic var camera: Camera? {
        
        willSet (newCamera) {

            if camera != nil {

                stopPreview()
            }
        }
        
        didSet (oldCamera) {

            if oldCamera != camera {
                
                startObservingCamera()
            }
            
            guard let camera = camera else {

                return
            }

            let previewState = NSApp.checkerController.cameraChecker.previewState(for: camera)
            
            startPreview(with: previewState)
        }
    }
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer! {
        
        didSet (oldLayer) {
            
            oldLayer?.removeFromSuperlayer()
            
            if let newLayer = previewLayer {
                
                contentView.layer!.addSublayer(newLayer)
            }
        }
    }

    override func didAddSubview(_ subview: NSView) {
        
        super.didAddSubview(subview)
        
        startObservingCamera()
    }
    
    override func willRemoveSubview(_ subview: NSView) {
        
        super.willRemoveSubview(subview)

        finishObservingCamera()
    }
    
    func startPreview(with previewState: CameraChecker.PreviewState) {
        
        guard let camera = camera else {
        
            NSLog("%@", "Cannot start preview on \(self) because no camera is specified.")
            return
        }
        
        NSLog("%@", "Starting \(camera) preview on \(self).")
        
        do {

            let input = try AVCaptureDeviceInput(device: camera.device)

            session = AVCaptureSession()
            
            guard session.canAddInput(input) else {
                
                NSLog("%@", "An input device could'nt be added: \(input)")
                return
            }
            
            session.sessionPreset = .low
            session.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.apply(previewState: previewState)
            
            updatePreviewFrame()
            
            session.startRunning()
        }
        catch {
            
            NSLog("%@", "\(camera) could not start preview: \(error)")
        }
    }
    
    func stopPreview() {

        defer {

            session?.stopRunning()

            previewLayer = nil
            session = nil
        }

        guard let camera = camera else {
            
            NSLog("%@", "Not need to stop preview because no camera is specified.")
            return
        }

        NSLog("%@", "Stopping \(camera) preview.")
    }

    func updatePreviewFrame() {
        
        previewLayer?.frame = contentView.bounds
    }
    
    @IBAction func expandButtonDidPush(_ sender: NSButton) {
        
        delegate?.cameraView?(self, expandButtonDidPush: sender)
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        
        super.resize(withOldSuperviewSize: oldSize)
        
        updatePreviewFrame()
    }
    
    func applyCaptureImage(_ sampleBuffer: CMSampleBuffer) {
        
        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task.detached { [self] in

            let image = NSImage(sampleBuffer: sampleBuffer.instance)
            
            Task { @MainActor in
                
                currentCaptureImage = image
            }
        }
    }
}

private extension CameraView {
    
    func startObservingCamera() {
        
        guard let camera else {
        
            finishObservingCamera()
            return
        }
        
        Task {
            cameraObserver = CameraObserver(view: self)
            videoCapture = await NSApp.videoCaptureManager.videoCapture(for: camera)
            await videoCapture?.addVideoCaptureObserver(cameraObserver)
        }
    }
    
    func finishObservingCamera() {

        guard camera != nil else {
        
            return
        }
        
        Task { [self] in
            
            await videoCapture?.removeVideoCaptureObserver(cameraObserver)
            videoCapture = nil
            cameraObserver = nil
        }
    }
}
