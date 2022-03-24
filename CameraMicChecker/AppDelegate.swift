//
//  AppDelegate.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AppKit
import USBDeviceDetector

@main @MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {

    nonisolated func applicationDidFinishLaunching(_ aNotification: Notification) {

        Task { @MainActor in
            
            try await NSApp.checkerController.prepare()
        }
    }

    nonisolated func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    nonisolated func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    nonisolated func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        true
    }
}

extension AppDelegate: CheckerControllerDelegate {
    
    nonisolated func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {

        Application.DevicesDidUpdateNotification(checkerController: checkerController).post()
    }
}
