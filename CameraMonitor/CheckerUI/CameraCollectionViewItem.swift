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
        
        NSLog(#"A camera collection view item for "\#(cameraView.camera!.name)" will appear."#)

        super.viewWillAppear()
        
        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, itemWillVisible: self)
    }
    
    override func viewDidAppear() {

        super.viewDidAppear()
        
        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, itemDidVisible: self)
        
        NSLog(#"A camera collection view item for "\#(cameraView.camera!.name)" did appear."#)
    }
    
    override func viewWillDisappear() {

        NSLog(#"A camera collection view item for "\#(cameraView.camera!.name)" will disappear."#)

        super.viewWillDisappear()

        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, itemWillInisible: self)
    }

    override func viewDidDisappear() {

        super.viewDidDisappear()

        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, itemDidInisible: self)

        NSLog(#"A camera collection view item for "\#(cameraView.camera!.name)" did disappear."#)
    }
}

extension CameraCollectionViewItem : CameraViewDelegate {
    
    func cameraView(_ view: CameraView, expandButtonDidPush button: NSButton) {
        
        let collectionView = cameraCollectionView
        let delegate = collectionView.delegate as? CameraCollectionViewDelegate
        
        delegate?.cameraCollectionView?(collectionView, expandButtonDidPush: button, on: self)
    }
}
