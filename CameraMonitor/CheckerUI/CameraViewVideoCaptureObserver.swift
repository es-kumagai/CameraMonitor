//
//  CameraViewVideoCaptureObserver.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/15
//  
//

import CoreMedia

extension CameraView {
    
    final class CameraObserver {
        
        let view: CameraView
        
        init(view: CameraView) {
            
            self.view = view
        }
    }
}

extension CameraView.CameraObserver : VideoCaptureObserver {
    
    func videoCapture(_ capture: VideoCapture, didOutput sampleBuffer: CMSampleBuffer) {

        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task { @MainActor in
            
            view.applyCaptureImage(sampleBuffer.instance)
        }
    }
    
    func videoCaptureDidRelease(_ capture: VideoCapture) {
        
    }
}
