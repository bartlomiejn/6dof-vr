//
//  PlayerNode.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 26/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class PlayerNode: SCNNode {
    
    private enum Constant {
        enum Measurement {
            static let height: CGFloat = 1.75
        }
        
        enum Translation {
            static let camera = SCNVector3(0.0, Measurement.height, 0.0)
        }
        
        enum Movement {
            static let time: TimeInterval = 1.0
        }
    }
    
    let cameraNode: VRCameraNode
    
    private var playerWorldPosition = simd_float3()
    
    private var motionPosition = simd_float3()
    private var motionRotation = simd_float4()
    
    init(startingPosition: simd_float3, camera: VRCameraNode) {
        playerWorldPosition = startingPosition
        self.cameraNode = camera
        
        super.init()
        
        camera.position = Constant.Translation.camera
        
        addChildNode(camera)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(_:_:_:)")
    }
    
    func updatePosition(with motionData: MotionData) {
        motionPosition = motionData.position
        motionRotation = motionData.rotation
        
        updateNodePosition()
        updateNodeOrientation()
    }
    
    func move(by offset: simd_float3) {
        playerWorldPosition = playerWorldPosition + offset
        
        updateNodePosition()
    }
    
    func move(to position: simd_float3, animated: Bool) {
        playerWorldPosition = position
        
        let action = SCNAction.move(to: SCNVector3(position + motionPosition), duration: Constant.Movement.time)
        action.timingMode = .easeInEaseOut
        runAction(action)
    }
    
    private func updateNodePosition() {
        simdPosition = playerWorldPosition + motionPosition
    }
    
    private func updateNodeOrientation() {
        cameraNode.simdRotation = motionRotation
    }
}
