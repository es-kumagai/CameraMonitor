//
//  Camera.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import AVFoundation

@objcMembers
final class Camera : NSObject {
    
    let device: AVCaptureDevice
    
    init(device: AVCaptureDevice) {

        self.device = device
    }
    
    dynamic var name: String {
        
        device.localizedName
    }
}
