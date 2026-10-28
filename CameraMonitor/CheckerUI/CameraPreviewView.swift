//
//  CameraPreviewView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/14.
//

import AppKit
import AVFoundation

@objc(ESCameraPreviewView)
@MainActor
final class CameraPreviewView : NSView {
    
    @UnsafeLazyInitializable
    private var cameraObserver: CameraObserver
    
    private var videoCapture: VideoCapture?

    @IBOutlet var captureImageView: NSImageView!
    
    var camera: Camera? {
        
        didSet (oldCamera) {

            if oldCamera != camera {
                
                observeCurrentCamera()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            cameraObserver = CameraObserver(view: self)
            
            captureImageView = NSImageView()
            
            captureImageView.imageFrameStyle = .grayBezel
            captureImageView.imageAlignment = .alignCenter
            captureImageView.imageScaling = .scaleProportionallyUpOrDown
            
            captureImageView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(captureImageView)
            
            let top = captureImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
            let bottom = captureImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
            let leading = captureImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
            let trailing = captureImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
            
            NSLayoutConstraint.activate([
                top, bottom, leading, trailing
            ])
        }
    }
    
    override func removeFromSuperview() {
        
        super.removeFromSuperview()
        
        Task {
            await videoCapture?.removeVideoCaptureObserver(cameraObserver)
        }
    }
}

extension CameraPreviewView {
    
    nonisolated
    func applyCaptureImage(_ sampleBuffer: CMSampleBuffer) {
        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task.detached { [self] in
            
            guard let image = NSImage(sampleBuffer: sampleBuffer.instance) else {
                
                return
            }

            await MainActor.run {
                captureImageView.image = image
            }
        }
    }
    
    func observeCurrentCamera() {
        
        Task.detached { [self] in

            let newVideoCapture: VideoCapture?
            let currentVideoCapture = await videoCapture
            
            switch await camera {
                
            case let camera?:
                newVideoCapture = await NSApp.videoCaptureManager.videoCapture(for: camera)
                await newVideoCapture!.addVideoCaptureObserver(cameraObserver)
                
            case nil:
                newVideoCapture = nil
            }

            await currentVideoCapture?.removeVideoCaptureObserver(cameraObserver)
            
            Task { @MainActor in
                
                videoCapture = newVideoCapture
            }
        }
    }
}
