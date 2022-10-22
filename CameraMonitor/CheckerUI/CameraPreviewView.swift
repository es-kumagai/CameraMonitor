//
//  CameraPreviewView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/14.
//

@preconcurrency import AppKit
import AVFoundation

@objc(ESCameraPreviewView)
@MainActor
final class CameraPreviewView : NSView {
    
    private var cameraObserver: CameraObserver!
    private var videoCapture: VideoCapture?

    @IBOutlet var captureImageView: NSImageView!
    
    dynamic var camera: Camera? {
        
        willSet (newCamera) {

            if camera != newCamera {

                finishObservingCamera()
            }
        }
        
        didSet (oldCamera) {

            if oldCamera != camera {
                
                startObservingCamera()
            }
        }
    }

    override func awakeFromNib() {
        
        super.awakeFromNib()

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
        
//        captureImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        captureImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        captureImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        captureImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        captureImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
//        captureImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
//        captureImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
    }
}

extension CameraPreviewView {
    
    func applyCaptureImage(_ sampleBuffer: CMSampleBuffer) {
        
        let sampleBuffer = UncheckedSendable(sampleBuffer)
        
        Task.detached { [self] in
            
            guard let image = NSImage(sampleBuffer: sampleBuffer.instance) else {
                
                return
            }
            
            Task { @MainActor in
                
                captureImageView.image = image
            }
        }
    }
    
    func startObservingCamera() {
        
        guard let camera else {
        
            finishObservingCamera()
            return
        }
        
        Task { [self] in
            cameraObserver = CameraObserver(view: self)
            videoCapture = await NSApp.videoCaptureManager.videoCapture(for: camera)
            #warning("ここで cameraObserver が nil になってしまうことがある。")
            await videoCapture?.addVideoCaptureObserver(cameraObserver)
        }
    }
    
    func finishObservingCamera() {

        guard camera != nil else {
        
            return
        }
        
        Task { [self] in
            
            await videoCapture?.removeVideoCaptureObserver(cameraObserver)
            videoCapture = nil
            cameraObserver = nil
        }
    }
}
