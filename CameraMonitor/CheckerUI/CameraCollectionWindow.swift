//
//  CameraCollectionWindow.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/27
//  
//

import Cocoa

@objc(ESCameraCollectionWindow)
@objcMembers @MainActor
class CameraCollectionWindow: NSWindow {

    #if DEBUG
    static let frameSaveName = "CameraCollectionWindow-Debug"
    #else
    static let frameSaveName = "CameraCollectionWindow"
    #endif

    func saveFrame() {
        
        saveFrame(usingName: Self.frameSaveName)
        NSLog("The camera monitor window's position has been saved.")
    }
    
    func restoreFrame() {
        
        switch setFrameUsingName(Self.frameSaveName) {
            
        case true:
            NSLog("The camera monitor window's position has been restored.")

        case false:
            NSLog("The camera monitor window's position couldn't be restored.")
        }
    }
}
