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
    }
    
    let cameraNode: VRCameraNode
    
    private var playerWorldPosition: SCNVector3
    
    private var motionPosition = SCNVector3Zero
    private var motionRotation = simd_float4()
    
    init(startingPosition: SCNVector3, camera: VRCameraNode) {
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
    
    func move(to position: SCNVector3) {
        playerWorldPosition = position
        
        updateNodePosition()
    }
    
    private func updateNodePosition() {
        position = motionPosition
    }
    
    private func updateNodeOrientation() {
        cameraNode.simdRotation = motionRotation
    }
}