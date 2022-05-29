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
    
    let usbDeviceDetectionDelay = 0.3
    let usbDeviceDetectionAuxiliaryDelay = 5.0
}

extension Application {

    struct DevicesDidUpdateNotification : NotificationProtocol {
        
        var checkerController: CheckerController
    }
}

extension Application : USBDeviceDetectorDelegate {
    
    nonisolated func usbDeviceDetector(_ detector: USBDeviceDetector, devicesDidAdd devices: USBDevices) {
        
        NSLog("%@", "USB devices have been added: \(devices)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + usbDeviceDetectionDelay) { [unowned self] in
            
            checkerController.updateDevices()
            
            // To detect slowly detecting devices, retry updating after `usbDeviceDetectionAuxiliaryDelay` again.
            DispatchQueue.main.asyncAfter(deadline: .now() + usbDeviceDetectionAuxiliaryDelay) { [unowned self] in
                
                checkerController.updateDevices()
            }
        }
    }
    
    nonisolated func usbDeviceDetector(_ detector: USBDeviceDetector, devicesDidRemove devices: USBDevices) {

        NSLog("%@", "USB devices have been removed: \(devices)")

        DispatchQueue.main.asyncAfter(deadline: .now() + usbDeviceDetectionDelay) { [unowned self] in

            checkerController.updateDevices()
        }
    }
}
