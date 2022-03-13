//
//  CheckerControllerDelegate.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import Foundation

@objc protocol CheckerControllerDelegate {
    
    @objc optional func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController)
}
