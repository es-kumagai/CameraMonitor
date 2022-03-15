//
//  App.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/02/26.
//

import Foundation
import AppKit
import Ocean

@objc(ESApplication) @objcMembers
final class Application : NSApplication {
    
    @IBOutlet var checkerController: CheckerController!
}

let NSApp = AppKit.NSApp as! Application

extension Application {

    struct DevicesDidUpdateNotification : NotificationProtocol {
        
        var checkerController: CheckerController
    }
}

extension Application : CheckerControllerDelegate {
    
    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {

        DevicesDidUpdateNotification(checkerController: checkerController).post()
    }
}
