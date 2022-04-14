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

@MainActor
extension Sequence where Element : SingleCameraWindowController {
    
    func closeAll() {

        forEach { $0.close() }
    }
    
    func having(camera: Camera) -> [Element] {

        filter {
            
            $0.singleCameraViewController.camera == camera
        }
    }
}

@MainActor
extension RangeReplaceableCollection where Element : SingleCameraWindowController {

    mutating func remove(_ singleCameraWindowController: SingleCameraWindowController) {
    
        singleCameraWindowController.close()

        remove(contentsAt: indexes { $0.singleCameraViewController === singleCameraWindowController })
    }
    
    mutating func remove(having camera: Camera) {
        
        for windowController in having(camera: camera) {

            NSLog("%@", "Removing single camera window controller for \(camera) on \(windowController).")
            
            remove(windowController)
        }
    }
    
    mutating func leave(onlyHaving cameras: Cameras) {
        
        for windowController in self {
            
            if !cameras.contains(windowController.singleCameraViewController.camera) {
                
                remove(windowController)
            }
        }
    }
}
