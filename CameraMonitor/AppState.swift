//
//  AppState.swift
//  CameraMonitor
//  
//  Created by Tomohiro Kumagai on 2022/08/25
//  
//

import Foundation

extension Application {
    
    enum State {

        private static let propertyListDecoder = PropertyListDecoder()
        private static let propertyListEncoder = PropertyListEncoder()

        static var userDefaults = UserDefaults.standard
    }
}

extension Application.State {
    

}

private extension Application.State {

    static let expandingCameraIDsKey = "ExpandingCameraIDs"
}

extension Application.State {

    static var expandingCameraWindowStates: ExpandingCameraWindowStates {
        
        get {
            
            do {

                return try userDefaults.data(forKey: Self.expandingCameraIDsKey).map { data in
                    
                    try propertyListDecoder.decode(ExpandingCameraWindowStates.self, from: data)
                } ?? []
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
        
        set (newStates) {
            
            do {
                let expandingCameraWindowsData = try propertyListEncoder.encode(newStates)
                
                userDefaults.set(expandingCameraWindowsData, forKey: Self.expandingCameraIDsKey)
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
