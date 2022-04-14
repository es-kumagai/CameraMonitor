//
//  CameraController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import Foundation
import AVFoundation

final class CameraManager {
    
    init() {

        guard case .authorized = AVCaptureDevice.authorizationStatus(for: .video) else {
            
            fatalError("Video is not permitted.")
        }
    }
    
    var systemCamera: Camera? {
        
        AVCaptureDevice.default(for: .video).map(Camera.init)
    }
    
    var cameras: Cameras {

        AVCaptureDevice
            .DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .externalUnknown], mediaType: .video, position: .unspecified)
            .devices
            .map(Camera.init)
//            .filter { $0.name != "NDI Video" }
    }
    
    func previewState(for camera: Camera) -> PreviewState {
        
        PreviewState()
    }
}
