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
    
    @MainActor
    override func awakeFromNib() {
        
        super.awakeFromNib()
        NSApp.cameraCollectionViewController = self
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
        
        do {
            try NSApp.state.save()
        }
        catch {
            NSLog("Failed to save the app's state: \(error.localizedDescription)")
        }

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
        restoreSingleCameraWindows()
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
        reorderExpandedSingleCameraWindows(for: controller.camera)
        saveSingleCameraWindowExpandingState()
    }
}

extension CameraCollectionViewController : CameraCollectionViewDelegate {
    
    func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem) {

        showSingleCameraWindow(for: item.cameraView.camera!)
        saveSingleCameraWindowExpandingState()
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

extension CameraCollectionViewController {
    
    func saveSingleCameraWindowExpandingState() {
    
        NSApp.state.expandingCameraWindows = presentedSingleCameraWindowControllers.compactMap {
            
            guard let camera = $0.camera else {
                
                return nil
            }
            
            let cameraID = camera.id
            let windowCount = numberOfSingleCameraWindowControllers(for: camera)
            
            return Application.State.ExpandingCameraWindow(cameraID: cameraID, windowCount: windowCount)
        }
    }
    
    func findSingleCameraWindowControllers(for camera: Camera) -> [SingleCameraWindowController] {
        
        presentedSingleCameraWindowControllers.filter {
            $0.camera == camera
        }
    }
    
    func numberOfSingleCameraWindowControllers(for camera: Camera) -> Int {
        
        findSingleCameraWindowControllers(for: camera).count
    }
    
    func reorderExpandedSingleCameraWindows(for camera: Camera) {
    
        for (offset, windowController) in findSingleCameraWindowControllers(for: camera).sorted().enumerated() {
            
            windowController.windowNumber = offset
        }
    }
    
    func showSingleCameraWindow(for camera: Camera) {
        
        if NSEvent.modifierFlags == .option {
        
            let windowNumber = numberOfSingleCameraWindowControllers(for: camera)
            SingleCameraWindowController.resetFrameAutosave(for: camera, windowNumber: windowNumber)
        }

        let windowController = singleCameraWindowController(for: camera)
                
        windowController.delegate = self
        windowController.showWindow(self)
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
        
        let windowNumber = numberOfSingleCameraWindowControllers(for: camera)
        let windowController = NSStoryboard.instantiateSingleCameraWindowController(with: camera, assigningWindowNumber: windowNumber)

        presentedSingleCameraWindowControllers.append(windowController)
        
        return windowController
    }
    
    func restoreSingleCameraWindows() {
    
        for camera in NSApp.checkerController.cameraDevices {
            
            restoreSingleCameraWindows(for: camera.id)
        }
    }
    
    @discardableResult
    /// Restore single camera windows expanded previously for `cameraID`;
    ///
    /// When the camera specified by `cameraID` is not exists, this process is will be ignored and returns `false`.
    ///
    /// - Parameter cameraID: A camera id for restore windows.
    /// - Returns: Whether the camera specified by camera id is connected currently.
    func restoreSingleCameraWindows(for cameraID: String) -> Bool {

        guard let camera = NSApp.checkerController.cameraDevices.having(id: cameraID) else {
            
            return false
        }

        let numberOfWindowsExpected = NSApp.state.expandingCameraWindows.numberOfWindows(ofCameraID: camera.id)
        let numberOfWindowsPresented = numberOfSingleCameraWindowControllers(for: camera)

        let numberOfWindowsRestoring = numberOfWindowsExpected - numberOfWindowsPresented
        
        for _ in 0 ..< numberOfWindowsRestoring {
            
            showSingleCameraWindow(for: camera)
        }
        
        return true
    }
}

