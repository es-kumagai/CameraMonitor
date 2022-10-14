//
//  CameraState.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/15.
//

import AVFoundation

extension CameraChecker {
    
    struct PreviewState {
        
        var uniqueID: String?
        var previewEnabled: Bool = true
        var videoGravity: AVLayerVideoGravity = .resizeAspect
        var videoMirrored: Bool = false
        var videoOrientation: AVCaptureVideoOrientation = .portrait
        var listingPriority: Int = 0
    }
}
