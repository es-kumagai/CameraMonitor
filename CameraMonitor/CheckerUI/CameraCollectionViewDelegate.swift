//
//  CameraCollectionViewDelegate.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import AppKit

@objc(ESCameraCollectionViewItemDelegate)
@MainActor
protocol CameraCollectionViewDelegate : NSCollectionViewDelegate {
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem)
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, itemWillVisible item: CameraCollectionViewItem)
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, itemDidVisible item: CameraCollectionViewItem)
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, itemWillInisible item: CameraCollectionViewItem)
    
    @objc optional func cameraCollectionView(_ view: CameraCollectionView, itemDidInisible item: CameraCollectionViewItem)
}
