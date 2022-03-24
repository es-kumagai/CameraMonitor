//
//  Storyboard.swift
//  CameraMicChecker
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
    
    static func instantiateSingleCameraWindowController(with camera: Camera) -> SingleCameraWindowController {
        
        let windowController = singleCameraWindow.instantiateInitialController() as! SingleCameraWindowController
        
        windowController.window!.title = camera.name
        windowController.singleCameraViewController.representedObject = camera
        
        return windowController
    }
}

@MainActor
extension NSNib {
    
    static let cameraCollectionViewItem = NSNib(nibNamed: "CameraCollectionViewItem", bundle: nil)
}
