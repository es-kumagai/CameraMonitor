//
//  App.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/02/26.
//

import AppKit
import Ocean
import USBDeviceDetector

@MainActor
let NSApp = Application.shared as! Application

@MainActor
@objc(ESApplication)
final class Application: NSApplication, @unchecked Sendable {
    
    @IBOutlet var usbDeviceDetector: USBDeviceDetector!
    @IBOutlet var checkerController: CheckerController!
}

extension Application {

    struct DevicesDidUpdateNotification : NotificationProtocol {
        
        var checkerController: CheckerController
    }
}

extension Application : USBDeviceDetectorDelegate {
    
    nonisolated func usbDeviceDetector(_ detector: USBDeviceDetector, devicesDidAdd devices: USBDevices) {
        
        Task { @MainActor in

            try! await Task.sleep(nanoseconds: 500_000)
            checkerController.updateDevices()
        }
    }
    
    nonisolated func usbDeviceDetector(_ detector: USBDeviceDetector, devicesDidRemove devices: USBDevices) {

        Task { @MainActor in

            try! await Task.sleep(nanoseconds: 500_000)
            checkerController.updateDevices()
        }
    }
}
