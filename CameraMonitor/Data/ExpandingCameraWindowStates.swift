//
//  ExpandingCameraWindowStates.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/26
//  
//

typealias ExpandingCameraWindowStates = Set<ExpandingCameraWindowState>

extension Set where Element == ExpandingCameraWindowState {
    
    func state(havingCameraID cameraID: String) -> Element? {
    
        first { $0.cameraID == cameraID }
    }
    
    func numberOfWindows(ofCameraID cameraID: String) -> Int {
    
        state(havingCameraID: cameraID)?.windowCount ?? 0
    }
    
    mutating func incrementWindowCount(forCameraID cameraID: String) {
        
        let state = state(havingCameraID: cameraID) ?? Element(cameraID: cameraID)
        
        update(with: state.incrementedWindowCount())
    }
    
    mutating func decrementWindowCount(forCameraID cameraID: String) {
        
        let state = state(havingCameraID: cameraID) ?? Element(cameraID: cameraID)
        
        update(with: state.decrementedWindowCount())
    }
}
