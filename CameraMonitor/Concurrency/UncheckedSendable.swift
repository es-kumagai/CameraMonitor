//
//  UncheckedSendable.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

import Foundation

@available(*, deprecated, message: "UncheckedSendable は、ビデオバッファーを不必要に持ち越してしまうため、非推奨です。")
struct UncheckedSendable<Instance> : @unchecked Sendable {
    
    let instance: Instance
    
    init(_ instance: Instance) {

        self.instance = instance
    }
}
