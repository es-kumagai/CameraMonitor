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
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        let camera = representedObject as! Camera
        let previewState = NSApp.checkerController.cameraManager.previewState(for: camera)
        
        cameraView.startPreview(camera: camera, with: previewState)
    }
    
    override func viewDidDisappear() {

        super.viewDidDisappear()
        cameraView.stopPreview()
    }
}
