//
//  AppDelegate.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AppKit
import USBDeviceDetector

@main @MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {

    @IBOutlet var cameraExpandMenu: NSMenu!
    
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
    
    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {

        updateExpandMenu()
        Application.DevicesDidUpdateNotification(checkerController: checkerController).post()
    }
}

private extension AppDelegate {
    
    func updateExpandMenu() {
        
        cameraExpandMenu.removeAllItems()
        
        for (offset, cameraDevice) in NSApp.checkerController.cameraDevices.enumerated() {

            let menuItem = NSMenuItem()

            menuItem.title = cameraDevice.name
            menuItem.action = #selector(AppDelegate.cameraExpandMenuItemDidSelect)
            menuItem.keyEquivalent = "\(offset + 1)"
            menuItem.representedObject = cameraDevice
            
            cameraExpandMenu.addItem(menuItem)
        }
    }
    
    @IBAction func cameraMonitorMenuItemDidSelect(_ menuItem: NSMenuItem) {
        
        NSApp.cameraCollectionWindowController.cameraCollectionWindow.makeKeyAndOrderFront(self)
    }
    
    @IBAction func cameraExpandMenuItemDidSelect(_ menuItem: NSMenuItem) {
        
        guard let camera = menuItem.representedObject as? Camera else {

            NSLog("No cameras assigned to a selected menu item.")
            return
        }
        
        let cameraCollectionViewController = NSApp.cameraCollectionViewController
        
        guard let presentingWindowCameraController = cameraCollectionViewController?.findSingleCameraWindowControllers(for: camera).first else {
            
            NSApp.cameraCollectionViewController.showSingleCameraWindow(for: camera)
            return
        }

        presentingWindowCameraController.window?.makeKeyAndOrderFront(self)
    }
}
