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
    
    func prepareVideoCapture(for camera: Camera) {
        
        guard !videoCaptures.contains(camera: camera) else {
            
            return
        }
        
        let videoCapture = try! VideoCapture(camera: camera)
        
        videoCaptures.append(videoCapture)
        
        Application.VideoCapturePreparedNotification(videoCapture: videoCapture).post()
    }
    
    func prepareVideoCaptures(for cameras: [Camera]) {
        
        let oldCameras = videoCaptures.map(\.camera)
        let difference = cameras.difference(from: oldCameras)

        var addedCameras = [Camera]()
        var removedCameras = [Camera]()
        
        for difference in difference {
            
            switch difference {
                
            case .insert(offset: _, element: let camera, associatedWith: _):
                addedCameras.append(camera)
                
            case .remove(offset: _, element: let camera, associatedWith: _):
                removedCameras.append(camera)
            }
        }
        
        addedCameras.forEach(prepareVideoCapture(for:))
        removedCameras.forEach(releaseVideoCapture(for:))
    }
    
    func releaseVideoCapture(for camera: Camera) {

        let targetIndexes = videoCaptures.indexes { $0.camera == camera }
        let targetVideoCaptures = targetIndexes.map { videoCaptures[$0] }

        videoCaptures.remove(contentsAt: targetIndexes)
        
        Task {
            
            await targetVideoCaptures.videoCapturesDidRelease()
        }

        targetVideoCaptures.forEach {
            
            Application.VideoCaptureReleasedNotification(videoCapture: $0).post()
        }
    }
}
