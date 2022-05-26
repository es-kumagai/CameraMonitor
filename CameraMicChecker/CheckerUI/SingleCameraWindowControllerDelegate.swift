//
//  SingleCameraViewControllerDelegate.swift
//  CameraMicChecker
//  
//  Created by Tomohiro Kumagai on 2022/05/26
//  
//

import Foundation

@MainActor
@objc protocol SingleCameraWindowControllerDelegate {
    
    @objc optional func singleCameraWindowControllerWillClose(_ controller: SingleCameraWindowController)
}
