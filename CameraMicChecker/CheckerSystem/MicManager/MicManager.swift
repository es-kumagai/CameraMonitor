//
//  MicController.swift
//  CameraMicChecker
//
//  Created by Tomohiro Kumagai on 2021/10/07.
//

import AVFoundation
//import AudioUnit

final class MicManager {

    let engine = AVAudioEngine()
    
    let queue = DispatchQueue(label: "MicController")
    
    var selectedMic: Mic?
    var monitoringBy: Mic?
    
    init() {

        guard case .authorized = AVCaptureDevice.authorizationStatus(for: .video) else {
            
            fatalError("Mic is not permitted.")
        }
    }
    
    var systemMic: Mic? {
        
        AVCaptureDevice.default(for: .audio).map(Mic.init)
    }
    
    var mics: Mics {

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified)
        
        return discoverySession.devices.map(Mic.init)
    }
    
    func startMonitoring() throws {
        
        guard let selectedMic = self.selectedMic, let monitoringBy = self.monitoringBy else {
            
            return
        }

        let input = try AVCaptureDeviceInput(mic: selectedMic)
        let output = AVCaptureAudioDataOutput()

//        var description = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: 0, componentManufacturer: 0, componentFlags: 0, componentFlagsMask: 0)
//        let unit = try AUAudioUnit(componentDescription: description)
//
//        var component: AudioComponent? = nil
//        
//        while let _ = AudioComponentFindNext(component, &description) {
//            
//            var name: CFString = nil
//            
//            AudioComponentCopyName(component!, &name)
//            
//            print(name)
//        }
//        
//        output.setSampleBufferDelegate(self, queue: queue)
        
//        session.inputs.forEach(session.removeInput)
//        session.outputs.forEach(session.removeOutput)
//        
//        session.addInput(input)
//        session.addOutput(output)
    }
}

//extension MicController : AVCaptureAudioDataOutputSampleBufferDelegate {
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        
//    }
//}
