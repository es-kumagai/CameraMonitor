//
//  SingleCameraViewController.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import Cocoa

@objc(ESSingleCameraViewController)
@MainActor
class SingleCameraViewController: NSViewController {

    @IBOutlet var cameraView: CameraView!
    
    dynamic var camera: Camera {
    
        representedObject as! Camera
    }

    override var representedObject: Any? {
        
        didSet {
    
            cameraView.camera = camera
        }
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
    }
    
    override func viewDidDisappear() {

        super.viewDidDisappear()
    }
}
