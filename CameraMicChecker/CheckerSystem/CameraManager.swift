//
//  CameraController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import Foundation
import AVFoundation

final class CameraManager {
    
    let session = AVCaptureSession()
    
    init() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            session.startRunning()
        
        default:
            fatalError("Video is not permitted.")
        }
    }
    
    deinit {
        
        session.stopRunning()
    }
    
    var systemCamera: Camera? {
        
        AVCaptureDevice.default(for: .video).map(Camera.init)
    }
    
    var cameras: [Camera] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .externalUnknown], mediaType: .video, position: .unspecified).devices.map(Camera.init)
    }
}
