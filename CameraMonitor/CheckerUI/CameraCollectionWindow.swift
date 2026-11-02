//
//  CameraCollectionWindow.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/27
//  
//

import Cocoa

/// The camera overview window with persistent size and position.
@objc(ESCameraCollectionWindow)
@objcMembers @MainActor
class CameraCollectionWindow: NSWindow {

    #if DEBUG
    /// The frame storage name for this build configuration.
    static let frameSaveName = "CameraCollectionWindow-Debug"
    #else
    /// The frame storage name for this build configuration.
    static let frameSaveName = "CameraCollectionWindow"
    #endif

    /// Whether initial restoration has completed and frame changes may be saved.
    private var hasRestoredFrame = false

    /// Save the current frame after initial restoration has completed.
    func saveFrame() {
        guard hasRestoredFrame else {
            return
        }
        
        saveFrame(usingName: Self.frameSaveName)
        NSLog("The camera monitor window's size and position have been saved.")
    }
    
    /// Restore the saved frame without allowing startup notifications to overwrite it.
    func restoreFrame() {
        hasRestoredFrame = false
        defer { hasRestoredFrame = true }
        
        switch setFrameUsingName(Self.frameSaveName) {
            
        case true:
            NSLog("The camera monitor window's size and position have been restored.")

        case false:
            NSLog("The camera monitor window's size and position couldn't be restored.")
        }
    }
}
