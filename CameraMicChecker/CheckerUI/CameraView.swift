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
        
    func startPreview(camera: Camera) {
        
        let input = try! AVCaptureDeviceInput(device: camera.device)

        session = AVCaptureSession()
        
        guard session.canAddInput(input) else {
        
            NSLog("%@", "An input device could'nt be added: \(input)")
            return
        }
        
        session.sessionPreset = .low
        session.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
//        guard previewLayer.connection!.isVideoMirroringSupported else {
//
//            NSLog("%@", "The input device don't support video mirroring: \(input)")
//            return
//        }

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection!.isVideoMirrored = false
        print(previewLayer.connection!.isVideoOrientationSupported, previewLayer.connection!.videoOrientation.rawValue)
        previewLayer.connection!.videoOrientation = .portrait
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
