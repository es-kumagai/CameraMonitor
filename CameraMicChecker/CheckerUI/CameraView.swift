//
//  CameraView.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AppKit
import AVFoundation

final class CameraView : NSView {
    
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var contentView: CameraPreviewView!
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer? {
        
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
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.apply(previewState: previewState)
        previewLayer.frame = bounds

        self.previewLayer = previewLayer

        session.startRunning()
    }
    
    func stopPreview() {

        session.stopRunning()

        previewLayer = nil
        session = nil
    }
}
