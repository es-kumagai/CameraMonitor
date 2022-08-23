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

    #if DEBUG
    static let frameSaveName = "CameraCollectionWindowController-Debug"
    #else
    static let frameSaveName = "CameraCollectionWindowController"
    #endif

    @MainActor
    override func awakeFromNib() {

        super.awakeFromNib()
        NSApp.cameraCollectionWindowController = self
    }

    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.setFrameAutosaveName(Self.frameSaveName)
    }
}
