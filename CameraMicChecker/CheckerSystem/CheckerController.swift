//
//  CheckerController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/08.
//

import Foundation
import AVFoundation

@objcMembers
@MainActor
final class CheckerController : NSObject {
    
    @IBOutlet var delegate: CheckerControllerDelegate?
    
    private(set) var cameraManager: CameraManager!
    private(set) var micManager: MicManager!
    
    private(set) var micDevices: [Mic] = []
    private(set) var cameraDevices: [Camera] = []
    
    private(set) var isReady: Bool = false

    func prepare() async throws {
        
        if isReady {
            return
        }
        
        guard await AVCaptureDevice.authorizationStatus(for: .video), await AVCaptureDevice.authorizationStatus(for: .audio) else {
            
            throw CheckerControllerError.mediaOperationIsNotPermitted
        }

        cameraManager = CameraManager()
        micManager = MicManager()
        
        isReady = true
        
        updateDevices()
    }
    
    func updateDevices() {

        guard isReady else {
            
            return
        }
        
        cameraDevices = cameraManager.cameras
        micDevices = micManager.mics
        
        delegate?.checkerControllerDevicesDidUpdate?(self)
    }
}
