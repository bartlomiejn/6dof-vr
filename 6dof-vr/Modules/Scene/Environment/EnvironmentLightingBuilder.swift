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
        
        let node = SCNNode()
        node.light = light
        node.eulerAngles = SCNVector3(-(Float.pi / 4.0), -Float.pi / 2.0, 0.0)
        
        scene.rootNode.addChildNode(node)
    }
}
