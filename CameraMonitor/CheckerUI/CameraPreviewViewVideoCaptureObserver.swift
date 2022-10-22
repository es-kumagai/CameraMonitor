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
        
        let view: CameraPreviewView
        
        init(view: CameraPreviewView) {
            
            self.view = view
        }
    }
}

extension CameraPreviewView.CameraObserver : VideoCaptureObserver {
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer) {

        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task { @MainActor in
            
            view.applyCaptureImage(sampleBuffer.instance)
        }
    }
    
    func videoCaptureDidRelease(_ capture: VideoCapture) {
        
    }
}
