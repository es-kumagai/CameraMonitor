//
//  UncheckedSendable.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/14
//  
//

struct UncheckedSendable<Instance> : @unchecked Sendable {
    
    let instance: Instance
    
    init(_ instance: Instance) {
        
        self.instance = instance
    }
}
