//
//  EnvironmentBuilder.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 26/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

struct EnvironmentBuilder {
    
    static let background = UIImage(named: "sky_map")
    
    func populate(_ scene: SCNScene) {
        addBoxNodes(to: scene.rootNode, count: 200)
        addFloorNode(to: scene.rootNode)
        addBackground(to: scene)
    }
    
    private func addBoxNodes(to node: SCNNode, count: Int) {
        for _ in 0..<count {
            let randomHeight = CGFloat.random(lowerLimit: 1.0, upperLimit: 20.0)
            let box = SCNNode(geometry:
                SCNBox(
                    width: CGFloat.random(lowerLimit: 0.5, upperLimit: 3.0),
                    height: randomHeight,
                    length: CGFloat.random(lowerLimit: 0.5, upperLimit: 3.0),
                    chamferRadius: 0.0))

            let x = CGFloat.random(lowerLimit: -100.0, upperLimit: 100.0)
            let y = CGFloat.random(lowerLimit: -100.0, upperLimit: 100.0)
            
            box.position = SCNVector3(
                x,
                0.0,
                CGFloat.random(lowerLimit: -100.0, upperLimit: 100.0))

            box.pivot = SCNMatrix4MakeTranslation(0.0, -Float(randomHeight / 2.0), 0.0)

            box.geometry?.firstMaterial?.lightingModel = .physicallyBased
            box.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            box.geometry?.firstMaterial?.roughness.contents = UIColor.darkGray
            box.geometry?.firstMaterial?.metalness.contents = UIColor.darkGray

            node.addChildNode(box)
        }
    }
    
    private func addFloorNode(to node: SCNNode) {
        let floor = SCNFloor()
        
        floor.reflectivity = 0.3
        
        let plane = SCNNode(geometry: floor)
        
        plane.position = SCNVector3(0.0, 0.0, 0.0)
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        
        node.addChildNode(plane)
    }
    
    private func addBackground(to scene: SCNScene) {
        let background = EnvironmentBuilder.background
        scene.background.contents = background
        
        scene.lightingEnvironment.contents = background
        scene.lightingEnvironment.intensity = 3.0
    }
}
