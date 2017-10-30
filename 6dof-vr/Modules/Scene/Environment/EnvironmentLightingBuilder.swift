//
//  EnvironmentLightingBuilder.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 26/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

struct EnvironmentLightingBuilder {
    
    func addLighting(to scene: SCNScene) {
//        addAmbientLighting(to: scene)
        addDirectionalLighting(to: scene)
    }
    
    private func addAmbientLighting(to scene: SCNScene) {
        let light = SCNLight()
        light.type = .ambient
        
        let node = SCNNode()
        node.light = light
        
        scene.rootNode.addChildNode(node)
    }
    
    private func addDirectionalLighting(to scene: SCNScene) {
        let light = SCNLight()
        light.type = .directional
        light.castsShadow = true
        light.zNear = 0.1
        light.zFar = 10.0
        light.shadowBias = 2.0
        
        let node = SCNNode()
        node.light = light
        node.position = SCNVector3(10.0, 20.0, 10.0)
        node.eulerAngles = SCNVector3(-(Float.pi / 3.9), -Float.pi / 1.9, 0.0)
        
        scene.rootNode.addChildNode(node)
    }
}
