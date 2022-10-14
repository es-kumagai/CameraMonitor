//
//  VideoCaptureObserver.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import AVFoundation

protocol VideoCaptureObserver : Sendable {
    
    var videoCaptureObserverIdentifier: String { get }
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer)
    func videoCaptureDidRelease(_ capture: VideoCapture)
}
