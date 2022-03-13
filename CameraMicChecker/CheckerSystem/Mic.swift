//
//  Mic.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import AVFoundation

@objcMembers
class Mic : NSObject {
    
    let device: AVCaptureDevice
    
    init(device: AVCaptureDevice) {
        
        self.device = device
    }
}

extension AVCaptureDeviceInput {
    
    convenience init(mic: Mic) throws {
        
        try self.init(device: mic.device)
    }
}

//extension AVCaptureDeviceOutput {
//    
//    convenience init(mic: Mic) throws {
//        
//        try self.init(device: mic.device)
//    }
//}
