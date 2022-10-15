//
//  VideoCaptureManager.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/15
//  
//

import Foundation

actor VideoCaptureManager {
    
    private(set) var videoCaptures: [VideoCapture] = []
    
    func videoCapture(for camera: Camera) -> VideoCapture {
        
        prepareVideoCapture(for: camera)
        
        return videoCaptures.videoCapture(havingCamera: camera)!
    }
    
    func updateVideoCapturesForAllCameras() async {
        
        let newCameras = await NSApp.checkerController.cameraDevices
        
        let oldCameras = videoCaptures.map(\.camera)
        let difference = newCameras.difference(from: oldCameras)

        var addedCameras = Cameras()
        var removedCameras = Cameras()
        
        for difference in difference {
            
            switch difference {
                
            case .insert(_, let camera, _):
                addedCameras.append(camera)
                
            case .remove(_, let camera, _):
                removedCameras.append(camera)
            }
        }
        
        NSLog("Following cameras have been added: \(addedCameras.names)")
        NSLog("Following cameras have been removed: \(removedCameras.names)")

        addedCameras.forEach(prepareVideoCapture(for:))
        removedCameras.forEach(releaseVideoCapture(for:))
    }
}

extension VideoCapture {
    
    func release() {
        
        Task.detached { [self] in
            
            await manager.releaseVideoCapture(self)
        }
    }
}

private extension VideoCaptureManager {
    
    func prepareVideoCapture(for camera: Camera) {
        
        guard !videoCaptures.contains(camera: camera) else {
            
            return
        }
        
        let videoCapture = try! VideoCapture(camera: camera, manager: self)
        
        videoCaptures.append(videoCapture)
        
        Application.VideoCapturePreparedNotification(videoCapture: videoCapture).post()
    }

    func releaseVideoCapture(_ videoCapture: VideoCapture) {
    
        videoCaptures.removeAll { $0 === videoCapture }
        
        Task.detached {
            
            for observer in await videoCapture.observers {
                
                observer.videoCaptureDidRelease(videoCapture)
            }
            
            Application.VideoCaptureReleasedNotification(videoCapture: videoCapture).post()
        }
    }
    
    func releaseVideoCapture(for camera: Camera) {

        let targetVideoCaptures = videoCaptures
            .indexes { $0.camera == camera }
            .map { videoCaptures[$0] }

        targetVideoCaptures.forEach(releaseVideoCapture(_:))
    }
}
