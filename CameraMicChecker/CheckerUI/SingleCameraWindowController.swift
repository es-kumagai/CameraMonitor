//
//  SingleCameraWindowController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import Cocoa

@objc(ESSingleCameraWindowController)
@MainActor
final class SingleCameraWindowController: NSWindowController {

    dynamic var singleCameraViewController: SingleCameraViewController {
    
        contentViewController as! SingleCameraViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
