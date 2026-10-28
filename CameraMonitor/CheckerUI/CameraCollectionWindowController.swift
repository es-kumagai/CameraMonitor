//
//  CameraCollectionWindowController.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/22
//  
//

import Cocoa

@objc(ESCameraCollectionWindowController)
@objcMembers @MainActor
final class CameraCollectionWindowController: NSWindowController {

    dynamic var cameraCollectionWindow: CameraCollectionWindow! {
        
        guard let window = window else {
            
            return nil
        }
        
        return (window as! CameraCollectionWindow)
    }

    override func windowDidLoad() {        
        super.windowDidLoad()
        
        NSApp.cameraCollectionWindowController = self
        cameraCollectionWindow.restoreFrame()
    }
}

extension CameraCollectionWindowController : @MainActor NSWindowDelegate {
    
    func windowDidMove(_ notification: Notification) {
        let window = notification.object as! CameraCollectionWindow
        window.saveFrame()
    }
    
    func windowDidResize(_ notification: Notification) {
        let window = notification.object as! CameraCollectionWindow
        window.saveFrame()
    }
}
