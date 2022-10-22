//
//  NSImage.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/22
//  
//

import AppKit
import AVFoundation

extension NSImage {
    
    convenience init?(sampleBuffer: CMSampleBuffer) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {

            return nil
        }
        
        self.init(imageBuffer: imageBuffer)
    }
    
    convenience init?(imageBuffer: CVImageBuffer) {
        
        let imageWidth = CVPixelBufferGetWidth(imageBuffer)
        let imageHeight = CVPixelBufferGetHeight(imageBuffer)
        let imageSize = CGSize(width: imageWidth, height: imageHeight)

        let image = CIImage(cvPixelBuffer: imageBuffer)
        
        self.init(image: image, size: imageSize)
    }
    
    convenience init?(image: CIImage, size: NSSize) {
        
        let context = CIContext()
        let imageRect = CGRect(origin: .zero, size: size)
        
        guard let image = context.createCGImage(image, from: imageRect) else {
            
            return nil
        }
                
        self.init(cgImage: image, size: size)
    }
}
