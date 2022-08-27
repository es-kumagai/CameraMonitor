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
class CameraCollectionWindowController: NSWindowController {

    dynamic var cameraCollectionWindow: CameraCollectionWindow! {
        
        guard let window = window else {
            
            return nil
        }
        
        return (window as! CameraCollectionWindow)
    }

    @MainActor
    override func awakeFromNib() {

        super.awakeFromNib()
        NSApp.cameraCollectionWindowController = self
    }

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        cameraCollectionWindow.restoreFrame()
    }
}

extension CameraCollectionWindowController : NSWindowDelegate {
    
    nonisolated
    func windowDidMove(_ notification: Notification) {
        
        let window = notification.object as! CameraCollectionWindow
        
        Task { @MainActor in

            window.saveFrame()
        }
    }
    
    nonisolated
    func windowDidResize(_ notification: Notification) {
        
        let window = notification.object as! CameraCollectionWindow
        
        Task { @MainActor in

            window.saveFrame()
        }
    }
}
