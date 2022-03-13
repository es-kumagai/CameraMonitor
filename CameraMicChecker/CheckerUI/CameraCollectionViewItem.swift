//
//  CameraCollectionViewItem.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit
import AVFoundation

@objcMembers
final class CameraCollectionViewItem : NSCollectionViewItem {
    
    @IBOutlet weak var cameraView: CameraView!
    
    var session: AVCaptureSession!
    
    override var representedObject: Any? {
    
        get {
            super.representedObject
        }
        
        set {
            super.representedObject = newValue
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        let camera = representedObject as! Camera
        let input = try! AVCaptureDeviceInput(device: camera.device)

        session = AVCaptureSession()
        
        guard session.canAddInput(input) else {
        
            print("An input device could'nt be added: \(input)")
            cameraView.wantsLayer = false
            return
        }
        
        session.sessionPreset = .low
        session.addInput(input)
        session.commitConfiguration()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        guard previewLayer.connection!.isVideoMirroringSupported else {

            print("The input device don't support video mirroring: \(input)")
            cameraView.wantsLayer = false
            return
        }

        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
        previewLayer.connection!.isVideoMirrored = false
        print(previewLayer.connection!.isVideoOrientationSupported, previewLayer.connection!.videoOrientation.rawValue)
        previewLayer.connection!.videoOrientation = .portrait
        previewLayer.frame = cameraView.bounds

        cameraView.wantsLayer = true
        cameraView.layer!.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    override func viewDidDisappear() {

        super.viewDidDisappear()
        
        session.stopRunning()
        session = nil
    }
}
