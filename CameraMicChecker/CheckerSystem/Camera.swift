//
//  Camera.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import AVFoundation

@objcMembers
final class Camera : NSObject, Identifiable {
    
    let device: AVCaptureDevice
    
    init(device: AVCaptureDevice) {

        self.device = device
    }
    
    dynamic var name: String {
        
        device.localizedName
    }
    
    dynamic var id: String {
        
        device.uniqueID
    }
    
    dynamic var modelID: String {
        
        device.modelID
    }
    
    dynamic var manufacturer: String {
        
        device.manufacturer
    }
    
    dynamic var transportType: Int32 {
        
        device.transportType
    }
    
    func hasMediaType(_ mediaType: AVMediaType) -> Bool {
        
        device.hasMediaType(mediaType)
    }
    
    dynamic var isConnected: Bool {
        
        device.isConnected
    }
    
    dynamic var isInUseByAnotherApplication: Bool {
        
        device.isInUseByAnotherApplication
    }
    
    dynamic var isSuspended: Bool {
        
        device.isSuspended
    }
}
