//
//  SingleCameraViewController.swift
//  CameraMicChecker
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

    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        let previewState = NSApp.checkerController.cameraManager.previewState(for: camera)
        
        cameraView.startPreview(camera: camera, with: previewState)
    }
    
    override func viewDidDisappear() {

        super.viewDidDisappear()
        cameraView.stopPreview()
    }
}
