//
//  ExpandingCameraWindowState.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/26
//  
//

struct ExpandingCameraWindowState : Codable {
    
    var cameraID: String
    var windowCount: Int
    
    init(cameraID: String, windowCount: Int) {
        
        self.cameraID = cameraID
        self.windowCount = max(windowCount, 0)
    }
}

extension ExpandingCameraWindowState : Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
    
        lhs.cameraID == rhs.cameraID
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(cameraID)
    }
}

extension ExpandingCameraWindowState {
    
    init(cameraID: String) {
        
        self.init(cameraID: cameraID, windowCount: 0)
    }
    
    var isWindowExists: Bool {
        
        windowCount >= 0
    }
    
    func incrementedWindowCount() -> Self {
        
        Self(cameraID: cameraID, windowCount: windowCount + 1)
    }

    func decrementedWindowCount() -> Self {
        
        Self(cameraID: cameraID, windowCount: windowCount - 1)
    }    
}
