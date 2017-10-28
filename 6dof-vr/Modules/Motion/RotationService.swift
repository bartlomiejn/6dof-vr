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
import simd

final class RotationService {
    
    var onRotationUpdate: ((simd_float4) -> Void)?
    
    var updateInterval = 1.0 / 60.0 {
        didSet {
            motionManager.deviceMotionUpdateInterval = updateInterval
        }
    }
    
    private let motionManager: CMMotionManager
    
    init(motionManager: CMMotionManager) {
        self.motionManager = motionManager
    }
    
    func startRotationUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 120.0
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, _ in
            guard let deviceMotion = deviceMotion else {
                return
            }
            
            let quat = simd_quatf(deviceMotion.attitude.quaternion)
            let correctedAxisAngle = simd_float4(
                quat.axis.y,
                quat.axis.z,
                -quat.axis.x,
                quat.angle)
            
            let correctedQuat = simd_quatf.fromAxisAngle(correctedAxisAngle)
            
            let viewportTiltAngle = Float(90.0.degreesToRadians)
            let tiltQuat = simd_quatf(
                ix: -1.0 * sin(viewportTiltAngle / 2),
                iy: 0.0 * sin(viewportTiltAngle / 2),
                iz: 0.0 * sin(viewportTiltAngle / 2),
                r: cos(viewportTiltAngle / 2))
            
            let correctedQuat2 = correctedQuat * tiltQuat
            
            let correctedAxisAngle2 = simd_float4(
                correctedQuat2.axis.x,
                correctedQuat2.axis.z,
                correctedQuat2.axis.y,
                correctedQuat2.angle)

            self?.onRotationUpdate?(correctedAxisAngle2)
        }
    }
}

