//
//  VRCameraNode.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 26/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class VRCameraNode: SCNNode {
    
    enum Constant {
        enum Camera {
            static let nearPlane: Double = 0.1
            static let farPlane: Double = 100.0
            static let fieldOfView: CGFloat = 1000.0
        }
        
        enum Distance {
            static let pupillary: CGFloat = 0.066
        }
        
        enum Translation {
            static let leftEye = SCNVector3(-Float(Distance.pupillary / 2.0), 0.0, 0.0)
            static let rightEye = SCNVector3(Float(Distance.pupillary / 2.0), 0.0, 0.0)
        }
    }

    let leftNode = SCNNode()
    let rightNode = SCNNode()
    
    private let left = SCNCamera()
    private let right = SCNCamera()
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupCamera(left)
        setupCamera(right)
        
        leftNode.camera = left
        leftNode.position = Constant.Translation.leftEye
        
        rightNode.camera = right
        rightNode.position = Constant.Translation.rightEye
        
        addChildNode(leftNode)
        addChildNode(rightNode)
    }
    
    private func setupCamera(_ camera: SCNCamera) {
        camera.zNear = Constant.Camera.nearPlane
        camera.zFar = Constant.Camera.farPlane
        camera.fieldOfView = Constant.Camera.fieldOfView
    }
}
