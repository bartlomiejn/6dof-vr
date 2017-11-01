//
//  MotionService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 25/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import CoreMotion
import ARKit
import simd

struct MotionData {
    static var zero: MotionData = MotionData(position: simd_float3(), rotation: simd_float4())
    
    let position: simd_float3
    let rotation: simd_float4
}

protocol MotionDataProvider: class {
    func startMotionUpdates()
}

final class MotionService: MotionDataProvider {
    
    private let motionManager: CMMotionManager
    private let session: ARSession
    
    var motionData: MotionData {
        return MotionData(
            position: position(from: session.currentFrame),
            rotation: correctedRotation(from: motionManager.deviceMotion?.attitude.quaternion))
    }

    init(motionManager: CMMotionManager, session: ARSession) {
        self.motionManager = motionManager
        self.session = session
    }

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        // TODO: Temporarily switched off
//        session.run(ARWorldTrackingConfiguration())
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 120.0
        motionManager.startDeviceMotionUpdates()
    }
    
    private func position(from frame: ARFrame?) -> simd_float3 {
        guard let frame = frame else {
            return simd_float3()
        }
        
        let transformColumn = frame.camera.transform.columns.3
        
        return simd_float3(transformColumn.x, transformColumn.y, transformColumn.z)
    }
    
    private func correctedRotation(from quaternion: CMQuaternion?) -> simd_float4 {
        guard let quaternion = quaternion else {
            return simd_float4()
        }
        
        let quat = simd_quatf(quaternion)
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
        
        return correctedAxisAngle2
    }
}
