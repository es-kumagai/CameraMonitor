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
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in

            switch AVCaptureDevice.authorizationStatus(for: mediaType) {
                
            case .authorized:
                continuation.resume(returning: true)
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
                
            case .denied, .restricted:
                continuation.resume(returning: false)
                
            @unknown default:
                continuation.resume(returning: false)
            }
        }
    }
}
