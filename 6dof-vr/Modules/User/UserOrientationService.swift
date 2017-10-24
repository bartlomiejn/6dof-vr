//
//  UserOrientationService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import SceneKit
import CoreMotion

final class UserOrientationService {
    
    var onOrientationUpdate: ((SCNVector3) -> Void)?
    
    var updateInterval = 1.0 / 60.0 {
        didSet {
            motionManager.deviceMotionUpdateInterval = updateInterval
        }
    }
    
    private let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }
    
    func startOrientationUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, error in
            
            let orientation = SCNVector3(
                -Float(deviceMotion!.attitude.roll) - (Float.pi / 2.0),
                Float(deviceMotion!.attitude.yaw),
                -Float(deviceMotion!.attitude.pitch))
            
            self?.onOrientationUpdate?(orientation)
        }
    }
}

