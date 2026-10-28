//
//  VideoCaptureObserverUnownedContainer.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/23
//  
//

import AVFoundation

struct UnownedVideoCaptureObserver {
    
    unowned let instance: VideoCaptureObserver
    
    init(_ instance: VideoCaptureObserver) {
        
        self.instance = instance
    }
}

extension Sequence where Element == UnownedVideoCaptureObserver {
    
    func contains(_ observer: VideoCaptureObserver) -> Bool {
        
        map(\.instance).contains(observer)
    }
}
