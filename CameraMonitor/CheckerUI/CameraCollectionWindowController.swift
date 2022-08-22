//
//  CameraCollectionWindowController.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/22
//  
//

import Cocoa

@objc(ESCameraCollectionWindow)
@objcMembers @MainActor
class CameraCollectionWindowController: NSWindowController {
    
    static let frameSaveName = "CameraCollectionWindowController"

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.setFrameAutosaveName(Self.frameSaveName)
    }
}
