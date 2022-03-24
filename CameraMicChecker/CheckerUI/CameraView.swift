//
//  CameraView.swift
//  CameraMicChecker
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
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer! {
        
        didSet (oldLayer) {
            
            oldLayer?.removeFromSuperlayer()
            
            if let newLayer = previewLayer {
                
                contentView.layer!.addSublayer(newLayer)
            }
        }
    }
        
    func startPreview(camera: Camera, with previewState: CameraManager.PreviewState) {
        
        let input = try! AVCaptureDeviceInput(device: camera.device)

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
    
    func stopPreview() {

        session.stopRunning()

        previewLayer = nil
        session = nil
    }
    
    func updatePreviewFrame() {
        
        previewLayer.frame = contentView.bounds
    }
    
    @IBAction func expandButtonDidPush(_ sender: NSButton) {
        
        delegate?.cameraView?(self, expandButtonDidPush: sender)
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        
        super.resize(withOldSuperviewSize: oldSize)
        
        updatePreviewFrame()
    }
}
