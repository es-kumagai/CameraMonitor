//
//  CameraCollectionViewController.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit
import Ocean
import AVFoundation
import USBDeviceDetector

@objcMembers @MainActor
final class CameraCollectionViewController: NSViewController, NotificationObservable {

    var presentedSingleCameraWindowControllers: [SingleCameraWindowController] = [] {
        
        didSet {

            updateExpandButtonsState()
        }
    }
    
    @IBOutlet weak var cameraCollectionView: CameraCollectionView! {
        
        didSet {

            cameraCollectionView.register(.cameraCollectionViewItem, forItemWithIdentifier: .init("CameraCollectionViewItem"))
        }
    }
    
    @IBOutlet var cameraArrayController: NSArrayController!

    var notificationHandlers = Notification.Handlers()
    
    dynamic var cameras = Cameras() {
        
        willSet (newCameras) {
            
//            let difference = newCameras.difference(from: cameras)
//            var addedCameras = Set<Camera>()
//            var removedCameras = Set<Camera>()
//
//            for change in difference {
//
//                switch change {
//
//                case .insert(offset: _, element: let camera, associatedWith: _):
//                    addedCameras.insert(camera)
//
//                case .remove(offset: _, element: let camera, associatedWith: _):
//                    removedCameras.insert(camera)
//                }
//            }
//
//            for removedCamera in removedCameras.subtracting(addedCameras) {
//
//                NSLog("%@", "Removing single camera window controller for \(removedCamera).")
//
//                presentedSingleCameraWindowControllers.remove(having: removedCamera)
//            }
        }
    }
    
    deinit {

        notificationHandlers.releaseAll()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        reloadCameras()

        observe(Application.DevicesDidUpdateNotification.self) { [unowned self] notification in
            
            reloadCameras()
        }
    }
    
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        
        presentedSingleCameraWindowControllers.closeAll()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func reloadCameras() {

        cameras = NSApp.checkerController.cameraDevices
        
        presentedSingleCameraWindowControllers.leave(onlyHaving: cameras)
    }
}

extension CameraCollectionViewController : CheckerControllerDelegate {

    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {
        
        reloadCameras()
    }
}

extension CameraCollectionViewController : SingleCameraWindowControllerDelegate {
    
    func singleCameraWindowControllerWillClose(_ controller: SingleCameraWindowController) {
        
        presentedSingleCameraWindowControllers.remove(controller, callCloseMethod: false)
    }
}

extension CameraCollectionViewController : CameraCollectionViewDelegate {
    
    func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem) {
        
        let camera = item.cameraView.camera!

        if NSEvent.modifierFlags == .option {
        
            SingleCameraWindowController.resetFrameAutosave(for: camera)
        }

        let windowController = singleCameraWindowController(for: camera)
                
        windowController.delegate = self
        windowController.showWindow(self)
    }

    nonisolated func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        let item = item as! CameraCollectionViewItem

        Task { @MainActor in

            NSLog("%@ will display.", item)
            item.cameraView.updatePreviewFrame()
        }
    }
    
    nonisolated func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        let item = item as! CameraCollectionViewItem
        
        Task { @MainActor in
            
            NSLog("%@ did end displaying.", item)
        }
    }
}

private extension CameraCollectionViewController {

    func updateExpandButtonsState() {
        
        for case let item as CameraCollectionViewItem in cameraCollectionView.visibleItems() {

            guard let camera = item.cameraView.camera else {
                
                continue
            }
            
            let itemHavingCamera = presentedSingleCameraWindowControllers.contains(camera: camera)
            
            item.expandButton.state = itemHavingCamera ? .on : .off
        }
    }
    
    func singleCameraWindowController(for camera: Camera) -> SingleCameraWindowController {
        
        NSLog("%@", "Creating new single camera window controller for \(camera).")
        
        let windowController = NSStoryboard.instantiateSingleCameraWindowController(with: camera)
        
        presentedSingleCameraWindowControllers.append(windowController)
        
        return windowController
    }
}

