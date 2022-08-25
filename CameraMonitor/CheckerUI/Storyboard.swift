//
//  Storyboard.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit

@MainActor
extension NSStoryboard.Name {

    static let singleCameraWindow = NSStoryboard.Name("SingleCameraWindow")
}

@MainActor
extension NSStoryboard {
    
    static let singleCameraWindow = NSStoryboard(name: .singleCameraWindow, bundle: nil)
    
    static func instantiateSingleCameraWindowController(with camera: Camera, assigningWindowNumber windowNumber: Int) -> SingleCameraWindowController {
        
        let windowController = singleCameraWindow.instantiateInitialController() as! SingleCameraWindowController
        
        windowController.camera = camera
        windowController.windowNumber = windowNumber
        
        windowController.restoreFrame()

        return windowController
    }
}

@MainActor
extension NSNib {
    
    static let cameraCollectionViewItem = NSNib(nibNamed: "CameraCollectionViewItem", bundle: nil)
}
