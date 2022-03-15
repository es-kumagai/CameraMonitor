//
//  App.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/02/26.
//

import Foundation
import AppKit
import Ocean

@MainActor
let App = Application()

@MainActor
final class Application: @unchecked Sendable {
    
    var checkerController: CheckerController
    
    init() {
        
        checkerController = CheckerController()
    }
}

extension Application {

    struct DevicesDidUpdateNotification : NotificationProtocol {
        
        var checkerController: CheckerController
    }
}
