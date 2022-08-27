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
        
        setFrameUsingName(Self.frameSaveName)
        NSLog("The camera monitor window's position has been restored.")
    }
}
