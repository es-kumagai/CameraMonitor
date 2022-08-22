//
//  AVCaptureDevice.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/02/27.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    
    static func authorizationStatus(for mediaType: AVMediaType) async -> Bool {
        
        await withCheckedContinuation { (contiguation: CheckedContinuation<Bool, Never>) in

            switch AVCaptureDevice.authorizationStatus(for: mediaType) {
                
            case .authorized:
                contiguation.resume(returning: true)
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: mediaType, completionHandler: contiguation.resume(returning:))
                
            case .denied, .restricted:
                contiguation.resume(returning: false)
                
            @unknown default:
                contiguation.resume(returning: false)
            }
        }
    }
}
