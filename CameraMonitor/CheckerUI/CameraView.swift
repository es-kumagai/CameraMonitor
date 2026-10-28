//
//  CameraView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AppKit

@objc(ESCameraView)
@MainActor
final class CameraView : NSView {
    
    @IBOutlet weak var delegate: CameraViewDelegate?

    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var expandButton: NSButton!
    @IBOutlet var contentView: CameraPreviewView!

    dynamic var camera: Camera? {
        
        didSet (oldCamera) {

            contentView.camera = camera
        }
    }
    
    @IBAction func expandButtonDidPush(_ sender: NSButton) {
        
        delegate?.cameraView?(self, expandButtonDidPush: sender)
    }
}
