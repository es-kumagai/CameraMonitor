//
//  SingleCameraWindowController.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/24.
//

import Cocoa

@objc(ESSingleCameraWindowController)
@MainActor
final class SingleCameraWindowController: NSWindowController {

    @IBOutlet dynamic weak var delegate: SingleCameraWindowControllerDelegate?

    dynamic var singleCameraViewController: SingleCameraViewController {
    
        contentViewController as! SingleCameraViewController
    }
    
    static func frameSaveName(for camera: Camera, windowNumber: Int) -> String {
        
        #if DEBUG
        return "SingleCameraWindowController-Debug:\(camera.id):\(windowNumber)"
        #else
        return "SingleCameraWindowController:\(camera.id):\(windowNumber)"
        #endif
    }
    
    var windowNumber: Int = 0 {
        
        didSet {
            
            updateWindowTitle()
        }
    }
    
    var camera: Camera! {
        
        didSet {
            
            updateWindowTitle()

            singleCameraViewController.representedObject = camera
        }
    }
    
    var isCameraConnected: Bool {
    
        singleCameraViewController.isCameraConnected
    }
    
    func updateWindowTitle() {

        var title: String {
            
            switch windowNumber {
                
            case 0:
                return camera.name

            case let number:
                return "\(camera.name) #\(number)"
            }
        }
        
        window?.title = title
    }

    var frameSaveName: String? {
    
        guard let camera = camera else {
            
            return nil
        }
        
        return Self.frameSaveName(for: camera, windowNumber: windowNumber)
    }
    
    @discardableResult
    func restoreFrame() -> Bool {
    
        guard let name = frameSaveName, let window = window else {
            
            return false
        }
        
        window.setFrameUsingName(name)
        NSLog("Frame state has been restored on \(window.title)")
        
        // フレームとレイヤーを合わせるために呼び出していますが、呼び出さなくてもどこか適切な場所で連携が取れるようにするのが最適解と思われます。
        singleCameraViewController.cameraView.updatePreviewFrame()
        
        return true
    }
    
    @discardableResult
    func saveFrame() -> Bool {
    
        guard let name = frameSaveName, let window = window else {
            
            return false
        }
        
        window.saveFrame(usingName: name)
        NSLog("Frame state has been saved on \(window.title)")
        
        return true
    }
    
    static func resetFrameAutosave(for camera: Camera, windowNumber: Int) {
        
        NSWindow.removeFrame(usingName: frameSaveName(for: camera, windowNumber: windowNumber))
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window!.delegate = self
    }
    
    override func close() {
        
        saveFrame()
        super.close()
    }
}

extension SingleCameraWindowController : NSWindowDelegate {
    
    nonisolated func windowWillClose(_ notification: Notification) {

        Task { @MainActor in

            saveFrame()
            delegate?.singleCameraWindowControllerWillClose?(self)
        }
    }
}

@MainActor
extension Sequence where Element : SingleCameraWindowController {
    
    func closeAll() {

        forEach { $0.close() }
    }
    
    func having(camera: Camera) -> [Element] {

        filter {
            
            $0.singleCameraViewController.camera == camera
        }
    }
}

@MainActor
extension RangeReplaceableCollection where Element : SingleCameraWindowController {

    func contains(camera: Camera) -> Bool {

        contains {
            
            $0.singleCameraViewController.camera == camera
        }
    }
    
    mutating func remove(_ singleCameraWindowController: SingleCameraWindowController) {
    
        singleCameraWindowController.close()

        remove(contentsAt: indexes { $0 === singleCameraWindowController })
    }
    
    mutating func remove(having camera: Camera) {
        
        for windowController in having(camera: camera) {

            NSLog("%@", "Removing single camera window controller for \(camera) on \(windowController).")
            
            remove(windowController)
        }
    }
    
    var assignedCameras: Set<Camera> {
        
        Set(map(\.camera))
    }
    
    /// Keep single camera windows only having `cameras`.
    ///
    /// - Parameter cameras: Cameras for leaving windows that have.
    mutating func keep(onlyHaving cameras: Cameras) {
        
        for windowController in self {
            
            if !cameras.contains(windowController.camera) {
                
                remove(windowController)
            }
        }
    }
}

extension Sequence where Element == SingleCameraWindowController {
    
    @MainActor
    func sorted() -> [Element] {
        
        sorted { $0.windowNumber < $1.windowNumber }
    }
}
