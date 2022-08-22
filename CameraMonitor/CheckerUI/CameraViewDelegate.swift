//
//  CameraViewDelegate.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import AppKit

@objc(ESCameraViewDelegate)
@MainActor
protocol CameraViewDelegate : AnyObject {
    
    @objc optional func cameraView(_ view: CameraView, expandButtonDidPush button: NSButton)
}
