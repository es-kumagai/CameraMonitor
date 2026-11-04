//
//  CameraPreviewViewVideoCaptureObserver.swift
//  CameraMonitor
//
//  Created by Tomohiro Kumagai on 2022/10/15
//

import CoreGraphics

/// The bounded image receiver used by each preview subscription.
extension CameraPreviewView {

    /// A single-consumer image stream that keeps only the newest pending frame.
    ///
    /// The receiver has no reference to a view. Finishing or cancelling consumption rejects
    /// further frames, including callbacks already in flight during observer removal.
    final class CameraObserver: Sendable {

        /// Rendered images awaiting presentation, with a capacity of one pending image.
        let images: AsyncStream<CGImage>

        /// The thread-safe producer for images from the capture callback queue.
        private let continuation: AsyncStream<CGImage>.Continuation

        /// Create an independent stream for one subscription lifetime.
        init() {
            let (images, continuation) = AsyncStream.makeStream(of: CGImage.self, bufferingPolicy: .bufferingNewest(1))
            self.images = images
            self.continuation = continuation
        }

        /// Replace an older pending image without waiting for the main actor.
        func receive(_ image: CGImage) {
            continuation.yield(image)
        }

        /// End delivery and wake the consumer, even when the camera has stopped producing frames.
        func finish() {
            continuation.finish()
        }
    }
}

/// Capture callbacks that feed the subscription's bounded image stream.
extension CameraPreviewView.CameraObserver : VideoCaptureObserver {

    /// Enqueue the newest rendered frame without retaining a camera sample buffer.
    func videoCapture(_ capture: VideoCapture, didOutput image: CGImage) {
        receive(image)
    }

    /// Finish the stream when the manager releases the camera.
    func videoCaptureDidRelease(_ capture: VideoCapture) {
        finish()
    }
}
