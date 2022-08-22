//
//  CheckerControllerError.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/02/26.
//

import Foundation

enum CheckerControllerError : Error {
    
    case mediaOperationIsNotPermitted
}

extension CheckerControllerError : CustomStringConvertible {

    var description: String {
        
        switch self {
            
        case .mediaOperationIsNotPermitted:
            return "Media operation is not permitted."
        }
    }
}

extension CheckerControllerError : CustomNSError {
    
    var errorCode: Int {
        1
    }
    
    static var errorDomain: String {
        "CheckerControllerError"
    }
    
    var errorUserInfo: [String : Any] {
        
        [NSLocalizedDescriptionKey : description]
    }
}
