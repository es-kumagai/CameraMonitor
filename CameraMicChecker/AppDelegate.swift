//
//  AppDelegate.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        Task { @MainActor in
            
            App.checkerController.delegate = self

            try await App.checkerController.prepare()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        true
    }
}

extension AppDelegate: CheckerControllerDelegate {
    
    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {

        Application.DevicesDidUpdateNotification(checkerController: checkerController).post()
    }
}
