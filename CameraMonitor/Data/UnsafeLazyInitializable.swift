//
//  UnsafeLazyInitializable.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/10/23
//  
//

@propertyWrapper
struct UnsafeLazyInitializable<Instance> {
    
    var instance: Instance?
    
    init() {

        instance = nil
    }
    
    init(instance: Instance) {

        self.instance = instance
    }
    
    var wrappedValue: Instance {
        
        get {

            guard isAssigned else {

                fatalError("No instances are not assigned.")
            }
            
            return instance!
        }
        
        set (newInstance) {

            guard !isAssigned else {

                fatalError("An instance is already assigned.")
            }
            
            instance = newInstance
        }
    }
    
    var projectedValue: Instance? {
        
        instance
    }
    
    var isAssigned: Bool {
        
        instance != nil
    }
}
