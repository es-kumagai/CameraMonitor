//
//  Storyboard.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit

extension NSStoryboard.Name {

    static let cameraCollectionViewItem = NSStoryboard.Name("CameraCollectionViewItem")
}

extension NSStoryboard {
    
    var cameraCollectionViewItem: CameraCollectionViewItem {
        
        instantiateController(withIdentifier: .cameraCollectionViewItem) as! CameraCollectionViewItem
    }
}

extension NSNib {
    
    static let cameraCollectionViewItem = NSNib(nibNamed: "CameraCollectionViewItem", bundle: nil)
}
