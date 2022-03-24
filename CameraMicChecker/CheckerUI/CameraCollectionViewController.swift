//
//  CameraCollectionViewController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit
import Ocean
import AVFoundation

@objcMembers @MainActor
final class CameraCollectionViewController: NSViewController, NotificationObservable {

    var currentSingleCameraWindowControllers: [SingleCameraWindowController] = []
    
    @IBOutlet weak var cameraCollectionView: CameraCollectionView! {
        
        didSet {

            cameraCollectionView.register(.cameraCollectionViewItem, forItemWithIdentifier: .init("CameraCollectionViewItem"))
        }
    }
    
    @IBOutlet var cameraArrayController: NSArrayController!

    var notificationHandlers = Notification.Handlers()
    
    dynamic var cameras = [Camera]()
    
    deinit {

        notificationHandlers.releaseAll()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        reloadCameras()

        observe(Application.DevicesDidUpdateNotification.self) { [unowned self] notification in
            
            reloadCameras()
        }

//        observe(notificationNamed: .AVRouteDetectorMultipleRoutesDetectedDidChange, object: nil) { [unowned self] notification in
//
//            print("DETECTED CHANGE")
//        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func reloadCameras() {

        cameras = NSApp.checkerController.cameraDevices
    }
}

extension CameraCollectionViewController : CheckerControllerDelegate {

    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {
        
        reloadCameras()
    }
}

extension CameraCollectionViewController : CameraCollectionViewDelegate {
    
    func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem) {
        
        let windowController = singleCameraWindowController(for: item.camera)
        windowController.showWindow(self)
    }

    nonisolated func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        let item = item as! CameraCollectionViewItem
        
        Task { @MainActor in
            
            item.cameraView.updatePreviewFrame()
        }
    }
}

private extension CameraCollectionViewController {

    func singleCameraWindowController(for camera: Camera) -> SingleCameraWindowController {
        
        let windowController = NSStoryboard.instantiateSingleCameraWindowController(with: camera)
        
        currentSingleCameraWindowControllers.append(windowController)

        return windowController
    }
}

//
//extension CameraCollectionViewController : NSCollectionViewDataSource {
//
//    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return cameras.count
//    }
//
//    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//
//        let item = storyboard!.cameraCollectionViewItem
//
//        item.camera = cameras[indexPath.section]
//
//        return item
//    }
//}
