//
//  Camera.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import AVFoundation

typealias Cameras = Array<Camera>

@objc(ESCamera)
@objcMembers
final class Camera : NSObject, Identifiable {
    
    let device: AVCaptureDevice
    
    init(device: AVCaptureDevice) {

        self.device = device
    }
    
    override var hash: Int {
        
        id.hash
    }
    
    override func isEqual(_ object: Any?) -> Bool {
    
        guard let object = object as? Camera else {
            
            return super.isEqual(object)
        }

        return id == object.id
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

extension Camera {
    
    override var description: String {
    
        "\(name) (ID:\(id))"
    }
    
    override var debugDescription: String {
        
        "<Camera for '\(name), id=\(id)' at \(ObjectIdentifier(self))>"
    }
}

extension Sequence where Element == Camera {
    
    func having(id: String) -> Camera? {
        
        first { $0.id == id }
    }
}
