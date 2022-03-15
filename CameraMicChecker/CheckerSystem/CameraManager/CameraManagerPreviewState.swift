//
//  CameraState.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/15.
//

import AVFoundation

extension CameraManager {
    
    struct PreviewState {
        
        var uniqueID: String?
        var previewEnabled: Bool = true
        var videoGravity: AVLayerVideoGravity = .resizeAspectFill
        var videoMirrored: Bool = false
        var videoOrientation: AVCaptureVideoOrientation = .portrait
    }
}
