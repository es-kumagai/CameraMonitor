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
    
    var expandedCameraWindowStates: ExpandingCameraWindowStates = []
    
    @IBOutlet weak var cameraCollectionView: CameraCollectionView! {
        
        didSet {

            cameraCollectionView.register(.cameraCollectionViewItem, forItemWithIdentifier: .init("CameraCollectionViewItem"))
        }
    }
    
    @IBOutlet var cameraArrayController: NSArrayController!

    var notificationHandlers = Notification.Handlers()
    
    dynamic var cameras = Cameras() {
        
        didSet {
            
            presentedSingleCameraWindowControllers.keep(onlyHaving: cameras)
            
            restoreSingleCameraWindows(considerPersistentData: false)
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

    override func viewDidAppear() {
 
        super.viewDidAppear()
    
        restoreSingleCameraWindows(considerPersistentData: true)
    }
    
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        
        saveSingleCameraWindowExpandingState()
        presentedSingleCameraWindowControllers.closeAll()
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

extension CameraCollectionViewController : SingleCameraWindowControllerDelegate {
    
    func singleCameraWindowControllerWillClose(_ controller: SingleCameraWindowController) {
        
        let camera = controller.camera!
        
        presentedSingleCameraWindowControllers.remove(controller)

        if controller.isCameraConnected {

            expandedCameraWindowStates.decrementWindowCount(forCameraID: camera.id)
        }
        
        reorderExpandedSingleCameraWindows(for: camera)
        saveSingleCameraWindowExpandingState()
    }
}

extension CameraCollectionViewController : CameraCollectionViewDelegate {
    
    func cameraCollectionView(_ view: CameraCollectionView, expandButtonDidPush button: NSButton, on item: CameraCollectionViewItem) {

        let camera = item.cameraView.camera!
        
        showSingleCameraWindow(for: camera)
        expandedCameraWindowStates.incrementWindowCount(forCameraID: camera.id)
        saveSingleCameraWindowExpandingState()
    }
    
    func cameraCollectionView(_ view: CameraCollectionView, itemWillVisible item: CameraCollectionViewItem) {
        
        updateExpandButtonsState(of: item)
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
    
        Application.State.expandingCameraWindowStates = expandedCameraWindowStates
    }
    
    func findSingleCameraWindowControllers(for camera: Camera) -> [SingleCameraWindowController] {
        
        presentedSingleCameraWindowControllers.filter {
            $0.camera == camera
        }
    }
    
    func numberOfSingleCameraWindowControllersInFact(for camera: Camera) -> Int {
        
        findSingleCameraWindowControllers(for: camera).count
    }
    
    func reorderExpandedSingleCameraWindows(for camera: Camera) {
    
        for (offset, windowController) in findSingleCameraWindowControllers(for: camera).sorted().enumerated() {
            
            windowController.windowNumber = offset
        }
    }
    
    func showSingleCameraWindow(for camera: Camera) {
        
        if NSEvent.modifierFlags == .option {
        
            let windowNumber = numberOfSingleCameraWindowControllersInFact(for: camera)
            SingleCameraWindowController.resetFrameAutosave(for: camera, windowNumber: windowNumber)
        }

        let windowController = singleCameraWindowController(for: camera)
                
        windowController.delegate = self
        windowController.showWindow(self)
    }
    
    func hideSingleCameraWindow(for camera: Camera) {
        
        presentedSingleCameraWindowControllers.remove(having: camera)
    }
}

private extension CameraCollectionViewController {

    func presentedSingleCameraWindowControllers(havingCameras cameras: Cameras) -> [SingleCameraWindowController] {
        
        presentedSingleCameraWindowControllers.filter {
            
            cameras.contains($0.camera)
        }
    }

    func presentedSingleCameraWindowControllers(notHavingCameras cameras: Cameras) -> [SingleCameraWindowController] {
        
        presentedSingleCameraWindowControllers.filter {
            
            !cameras.contains($0.camera)
        }
    }

    func updateExpandButtonsState() {
        
        for case let item as CameraCollectionViewItem in cameraCollectionView.visibleItems() {

            updateExpandButtonsState(of: item)
        }
    }
    
    func updateExpandButtonsState(of item: CameraCollectionViewItem) {
        
        guard let camera = item.cameraView.camera else {
            
            return
        }
        
        let itemHavingCamera = presentedSingleCameraWindowControllers.contains(camera: camera)
        
        item.expandButton.state = itemHavingCamera ? .on : .off
    }
    
    func singleCameraWindowController(for camera: Camera) -> SingleCameraWindowController {
        
        NSLog("%@", "Creating new single camera window controller for \(camera).")
        
        let windowNumber = numberOfSingleCameraWindowControllersInFact(for: camera)
        let windowController = NSStoryboard.instantiateSingleCameraWindowController(with: camera, assigningWindowNumber: windowNumber)

        presentedSingleCameraWindowControllers.append(windowController)
        
        return windowController
    }
    
    func restoreSingleCameraWindows(considerPersistentData: Bool) {
    
        if considerPersistentData {
            
            expandedCameraWindowStates = Application.State.expandingCameraWindowStates
        }
        
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

        let numberOfWindowsExpected = expandedCameraWindowStates.numberOfWindows(ofCameraID: camera.id)
        let numberOfWindowsPresented = numberOfSingleCameraWindowControllersInFact(for: camera)

        let numberOfWindowsRestoring = numberOfWindowsExpected - numberOfWindowsPresented
        
        for _ in 0 ..< numberOfWindowsRestoring {
            
            showSingleCameraWindow(for: camera)
        }
        
        return true
    }
}

