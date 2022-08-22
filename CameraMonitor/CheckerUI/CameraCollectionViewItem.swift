//
//  CameraCollectionViewItem.swift
// CameraMonitor
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
    @IBOutlet weak var expandButton: NSButton!
    
    dynamic var cameraCollectionView: CameraCollectionView {

        collectionView as! CameraCollectionView
    }
    
    override var representedObject: Any? {
        
        didSet {
            
            cameraView.camera = representedObject as? Camera
        }
    }
    
    override func viewWillAppear() {
        
        NSLog("%@", "A camera collection view item will appear: \(self)")

        super.viewWillAppear()
        
    }
    
    override func viewDidDisappear() {

        NSLog("%@", "A camera collection view item did disappear: \(self)")

        super.viewDidDisappear()

    }
}

extension CameraCollectionViewItem : CameraViewDelegate {
    
    func cameraView(_ view: CameraView, expandButtonDidPush button: NSButton) {
        
        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, expandButtonDidPush: button, on: self)
    }
}
