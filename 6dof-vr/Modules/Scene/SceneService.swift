//
//  SceneService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class SceneService {
    
    weak var view: VRViewType!
    
    let scene: SCNScene
    let camera = VRCameraNode()
    
    init(scene: SCNScene) {
        self.scene = scene
        
        EnvironmentBuilder().populate(scene)
        EnvironmentLightingBuilder().addLighting(to: scene)
    }
    
    func setupCamera() {
        scene.rootNode.addChildNode(camera)
        view.setPointOfView(to: camera)
    }
    
    func updated(userPosition: SCNVector3) {
        camera.position = userPosition
    }
    
    func updated(userOrientation: SCNVector3) {
        camera.eulerAngles = userOrientation
    }
}
