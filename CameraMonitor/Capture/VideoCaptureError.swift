//
//  VideoCaptureError.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

enum VideoCaptureError : Error {
    
    case cameraNotAcceptable(name: String, id: String)
    case internalError(String)
}
