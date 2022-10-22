//
//  AVCaptureVideoPreviewLayer.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/15.
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {

    func apply(previewState: CameraChecker.PreviewState) {
        
        videoGravity = previewState.videoGravity
        
        connection?.apply(previewState: previewState)
    }
}

extension AVCaptureConnection {
    
    func apply(previewState: CameraChecker.PreviewState) {

        videoOrientation = previewState.videoOrientation
        
        switch (isVideoMirroringSupported, automaticallyAdjustsVideoMirroring) {

        case (_, true):
            NSLog("%@", "The input device cannot be customized video mirroring.")
            
        case (true, false):
            isVideoMirrored = previewState.videoMirrored

        case (false, false) where previewState.videoMirrored == true:
            NSLog("%@", "The input device don't support video mirroring.")
            
        case (false, false):
            break
        }
    }
}
