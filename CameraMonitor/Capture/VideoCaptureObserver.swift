//
//  VideoCaptureObserver.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import AVFoundation

protocol VideoCaptureObserver : Sendable, AnyObject {
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer)
    func videoCaptureDidRelease(_ capture: VideoCapture)
}

extension Sequence where Element == VideoCaptureObserver {
    
    func contains(_ observer: Element) -> Bool {
        
        contains { $0 === observer }
    }
}
