//
//  CameraCollectionViewDelegate.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import AppKit

@objc(ESCameraCollectionViewItemDelegate)
@MainActor
protocol CameraCollectionViewDelegate : NSCollectionViewDelegate {
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem)
}
