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

extension simd_quatf {
    
    init(_ quat: CMQuaternion) {
        self.init(ix: Float(quat.x), iy: Float(quat.y), iz: Float(quat.z), r: Float(quat.w))
    }
}

final class OrientationService {
    
    var onEulerAnglesUpdate: ((SCNVector3) -> Void)?
    var onAxisAngleUpdate: ((SCNVector4) -> Void)?
    
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
            
            let simdQuat = simd_quatf(deviceMotion.attitude.quaternion)
            
            let axisAngle = SCNVector4(
                simdQuat.axis.y,
                simdQuat.axis.z,
                -simdQuat.axis.x,
                simdQuat.angle)
            let quatAxisAngle = simd_quatf(
                ix: axisAngle.x * sin(axisAngle.w / 2.0),
                iy: axisAngle.y * sin(axisAngle.w / 2.0),
                iz: axisAngle.z * sin(axisAngle.w / 2.0),
                r: cos(axisAngle.w / 2.0))
            
            let viewportCorrectionAngle = Float(90.0.degreesToRadians)
            let quatCorrection = simd_quatf(
                ix: -1.0 * sin(viewportCorrectionAngle / 2),
                iy: 0.0 * sin(viewportCorrectionAngle / 2),
                iz: 0.0 * sin(viewportCorrectionAngle / 2),
                r: cos(viewportCorrectionAngle / 2))
            let correctedQuat2 = quatAxisAngle * quatCorrection

            let axisAngle2 = SCNVector4(
                correctedQuat2.axis.x,
                correctedQuat2.axis.z,
                correctedQuat2.axis.y,
                correctedQuat2.angle)
            
            self?.onAxisAngleUpdate?(axisAngle2)
        }
    }
}

