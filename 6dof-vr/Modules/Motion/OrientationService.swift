//
//  OrientationService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import SceneKit
import CoreMotion

final class OrientationService {
    
    var onEulerAnglesUpdate: ((SCNVector3) -> Void)?
    var onAxisAngleQuaternionUpdate: ((SCNVector4) -> Void)?
    
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
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 120.0
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, _ in
            guard let deviceMotion = deviceMotion else {
                return
            }
            
            let thetaQuat = deviceMotion.attitude.quaternion

            var s = sqrt(1 - thetaQuat.w * thetaQuat.w)
            
            if s == 0 {
                s = 0.0001
            }
            
            let axisAngleQuat = SCNVector4(
                -(thetaQuat.y / s),
                thetaQuat.x / s,
                thetaQuat.z / s,
                2 * acos(thetaQuat.w))           // Angle in radians
            
//            let eulerAngles = SCNVector3(
//                -deviceMotion!.attitude.roll - Double.pi / 2.0,
//                deviceMotion!.attitude.yaw,
//                -deviceMotion!.attitude.pitch)
//
//            self?.onEulerAnglesUpdate?(SCNVector3(roll, pitch, yaw))
            
            self?.onAxisAngleQuaternionUpdate?(axisAngleQuat)
        }
    }
}

extension Double {
    
    var radiansToDegrees: Double {
        return self * (180 / .pi)
    }
}

