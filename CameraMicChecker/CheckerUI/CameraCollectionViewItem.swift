//
//  CameraCollectionViewItem.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit
import AVFoundation

@objc(ESCameraCollectionViewItem)
@objcMembers
@MainActor
final class CameraCollectionViewItem : NSCollectionViewItem {
    
    @IBOutlet weak var cameraView: CameraView!
    
    dynamic var camera: Camera {
    
        representedObject as! Camera
    }
    
    dynamic var cameraCollectionView: CameraCollectionView {

        collectionView as! CameraCollectionView
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

extension CameraCollectionViewItem : CameraViewDelegate {
    
    func cameraView(_ view: CameraView, expandButtonDidPush button: NSButton) {
        
        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, expandButtonDidPush: button, on: self)
    }
}
