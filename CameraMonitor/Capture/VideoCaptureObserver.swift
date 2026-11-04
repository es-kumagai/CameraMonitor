//
//  VideoCaptureObserver.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import CoreGraphics

/// A receiver of rendered camera images that never owns capture sample buffers.
protocol VideoCaptureObserver : Sendable, AnyObject {
    
    /// Receive an image synchronously on the camera's serial callback queue.
    ///
    /// Return promptly and bound any pending images retained for later display.
    func videoCapture(_ capture: VideoCapture, didOutput image: CGImage)

    /// End delivery when the manager releases the capture session.
    func videoCaptureDidRelease(_ capture: VideoCapture)
}

extension Sequence where Element == VideoCaptureObserver {
    
    func contains(_ observer: Element) -> Bool {
        
        contains { $0 === observer }
    }
}
