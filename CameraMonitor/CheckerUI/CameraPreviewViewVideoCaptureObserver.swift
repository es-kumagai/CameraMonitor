//
//  CameraPreviewViewVideoCaptureObserver.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/15
//  
//

import CoreMedia

extension CameraPreviewView {
    
    final class CameraObserver {
        
        unowned let view: CameraPreviewView
        
        init(view: CameraPreviewView) {
            
            self.view = view
        }
    }
}

extension CameraPreviewView.CameraObserver : VideoCaptureObserver {
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer) {

        view.applyCaptureImage(sampleBuffer)
    }
    
    func videoCaptureDidRelease(_ capture: VideoCapture) {
        
    }
}
