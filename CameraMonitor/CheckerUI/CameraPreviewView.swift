//
//  CameraPreviewView.swift
// CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/03/14.
//

import AppKit

/// A camera preview with one cancellable subscription for its current window attachment.
@objc(ESCameraPreviewView)
@MainActor
final class CameraPreviewView : NSView {

    /// The receiver belonging exclusively to the current subscription.
    private var cameraObserver: CameraObserver?

    /// The task that registers, displays, and unregisters the current receiver.
    private var observationTask: Task<Void, Never>?

    /// The image view displaying the latest rendered frame.
    @IBOutlet var captureImageView: NSImageView!

    /// The camera to display; changes replace the subscription and clear the old image.
    var camera: Camera? {
        didSet {
            if oldValue != camera {
                observeCurrentCamera()
            }
        }
    }

    /// Cancel delivery without retaining a disappearing view until another frame arrives.
    deinit {
        cameraObserver?.finish()
        observationTask?.cancel()
    }

    /// Configure the image view and begin observing if already attached to a window.
    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            captureImageView = NSImageView()
            captureImageView.imageFrameStyle = .grayBezel
            captureImageView.imageAlignment = .alignCenter
            captureImageView.imageScaling = .scaleProportionallyUpOrDown
            captureImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(captureImageView)

            NSLayoutConstraint.activate([
                captureImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                captureImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
                captureImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
                captureImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
            ])
            observeCurrentCamera()
        }
    }

    /// Stop when detached and resume when reattached, even if the camera has not changed.
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        observeCurrentCamera()
    }
}

/// Subscription replacement and main-actor presentation.
private extension CameraPreviewView {

    /// Replace the subscription with a unique receiver and discard stale asynchronous work.
    ///
    /// Each task removes only its own receiver, including when cancellation arrives during
    /// registration. The task holds the view weakly across suspension and buffers one image.
    func observeCurrentCamera() {
        cameraObserver?.finish()
        observationTask?.cancel()
        cameraObserver = nil
        observationTask = nil
        captureImageView?.image = nil

        guard window != nil, captureImageView != nil, let camera else {
            return
        }

        let observer = CameraObserver()
        let manager = NSApp.videoCaptureManager
        cameraObserver = observer

        observationTask = Task { [weak self] in
            let capture = await manager.videoCapture(for: camera)
            guard !Task.isCancelled else {
                return
            }
            await capture.addVideoCaptureObserver(observer)

            if !Task.isCancelled {
                for await image in observer.images {
                    guard !Task.isCancelled, let self, self.cameraObserver === observer else {
                        break
                    }
                    self.captureImageView.image = NSImage(cgImage: image, size: .zero)
                }
            }

            observer.finish()
            await capture.removeVideoCaptureObserver(observer)
        }
    }
}
