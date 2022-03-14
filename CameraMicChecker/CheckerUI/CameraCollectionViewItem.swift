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
        cameraView.startPreview(camera: representedObject as! Camera)
    }
    
    override func viewDidDisappear() {

        super.viewDidDisappear()
        cameraView.stopPreview()
    }
}
