//
//  CheckerController.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import AVFoundation

@objcMembers
@MainActor
final class CheckerController : NSObject {
    
    @IBOutlet var delegate: CheckerControllerDelegate?
    
    private(set) var cameraManager: CameraManager!
    private(set) var cameraDevices: Cameras = []
    
    private(set) var isReady: Bool = false

    func prepare() async throws {
        
        if isReady {
            return
        }
        
        guard await AVCaptureDevice.authorizationStatus(for: .video) else {
            
            throw CheckerControllerError.mediaOperationIsNotPermitted
        }

        cameraManager = CameraManager()
        
        isReady = true
        
        updateDevices()
    }
    
    func updateDevices() {

        guard isReady else {
            
            return
        }
        
        cameraDevices = cameraManager.cameras
        
        delegate?.checkerControllerDevicesDidUpdate?(self)
    }
}
