//
//  SingleCameraWindowController.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import Cocoa

@objc(ESSingleCameraWindowController)
@MainActor
final class SingleCameraWindowController: NSWindowController {

    @IBOutlet dynamic weak var delegate: SingleCameraWindowControllerDelegate?

    dynamic var singleCameraViewController: SingleCameraViewController {
    
        contentViewController as! SingleCameraViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window!.delegate = self
    }
}

extension SingleCameraWindowController : NSWindowDelegate {
    
    nonisolated func windowWillClose(_ notification: Notification) {

        Task { @MainActor in

            delegate?.singleCameraWindowControllerWillClose?(self)
        }
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

    func contains(camera: Camera) -> Bool {

        contains {
            
            $0.singleCameraViewController.camera == camera
        }
    }
    
    mutating func remove(_ singleCameraWindowController: SingleCameraWindowController, callCloseMethod: Bool = true) {
    
        if callCloseMethod {
            
            singleCameraWindowController.close()
        }

        remove(contentsAt: indexes { $0 === singleCameraWindowController })
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
