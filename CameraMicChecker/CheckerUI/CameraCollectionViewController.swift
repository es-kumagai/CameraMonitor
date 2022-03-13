//
//  CameraCollectionViewController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2022/03/11.
//

import AppKit
import Ocean

@objcMembers
final class CameraCollectionViewController: NSViewController, NotificationObservable {

    @IBOutlet weak var cameraCollectionView: NSCollectionView! {
        
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
            
            Task { @MainActor in
                
                reloadCameras()
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func reloadCameras() {

        cameras = NSApp.checkerController.cameraDevices
        print("RELOAD", cameras.count)
    }
}

extension CameraCollectionViewController : CheckerControllerDelegate {

    func checkerControllerDevicesDidUpdate(_ checkerController: CheckerController) {
        
        reloadCameras()
    }
}

extension CameraCollectionViewController : NSCollectionViewDelegate {

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
