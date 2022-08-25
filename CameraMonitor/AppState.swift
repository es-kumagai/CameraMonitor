//
//  AppState.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/25
//  
//

import Foundation

extension Application {
    
    class State {

        var userDefaults = UserDefaults.standard
        
        typealias ExpandingCameraWindows = [ExpandingCameraWindow]
        
        var expandingCameraWindows: ExpandingCameraWindows = []
        
        init() {
            
            do {
                try restore()
            }
            catch {
                NSLog("Failed to restore the app's state: \(error.localizedDescription)")
            }
        }
        
        deinit {
            
            do {
                try save()
            }
            catch {
                NSLog("Failed to save the app's state: \(error.localizedDescription)")
            }
        }
    }
}

extension Application.State {
    
    struct ExpandingCameraWindow : Codable {
        
        var cameraID: String
        var windowCount: Int
    }
}

private extension Application.State {

    static let expandingCameraIDsKey = "ExpandingCameraIDs"
}

extension Application.State {
    
    func save() throws {
        
        let encoder = PropertyListEncoder()
        
        let expandingCameraWindowsData = try encoder.encode(expandingCameraWindows)
        
        userDefaults.set(expandingCameraWindowsData, forKey: Self.expandingCameraIDsKey)
    }
    
    func restore() throws {
        
        let decoder = PropertyListDecoder()
        
        expandingCameraWindows = try userDefaults.data(forKey: Self.expandingCameraIDsKey).map { data in
            
            try decoder.decode(ExpandingCameraWindows.self, from: data)
        } ?? []
    }
}

extension Sequence where Element == Application.State.ExpandingCameraWindow {
    
    func numberOfWindows(ofCameraID cameraID: String) -> Int {
        
        first { $0.cameraID == cameraID }?.windowCount ?? 0
    }
}
