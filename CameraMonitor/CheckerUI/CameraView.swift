//
//  CameraView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AppKit
import AVFoundation

@objc(ESCameraView)
@MainActor
final class CameraView : NSView {
    
    @IBOutlet weak var delegate: CameraViewDelegate?

    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var expandButton: NSButton!
    @IBOutlet var contentView: CameraPreviewView!

    dynamic var camera: Camera? {
        
        willSet (newCamera) {

            if camera != nil {

                stopPreview()
            }
        }
        
        didSet {
            
            guard let camera = camera else {

                return
            }

            let previewState = NSApp.checkerController.cameraManager.previewState(for: camera)
            
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

    func startPreview(with previewState: CameraManager.PreviewState) {
        
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
}
