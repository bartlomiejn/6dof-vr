//
//  SceneService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class World {
    
    weak var view: VRViewType!
    
    let scene: SCNScene
    
    private let player: PlayerNode
    
    private weak var motionProvider: MotionDataProvider!
    
    init(scene: SCNScene) {
        self.scene = scene
        
        EnvironmentBuilder().populate(scene)
        EnvironmentLightingBuilder().addLighting(to: scene)
        
        player = PlayerNode(startingPosition: SCNVector3Zero, camera: VRCameraNode())
        
        scene.rootNode.addChildNode(player)
    }
    
    func setupMotionProvider(with provider: MotionDataProvider) {
        motionProvider = provider
        
        motionProvider!.onMotionUpdate = { [weak player] motionData in
            player?.updatePosition(with: motionData)
        }
        
        motionProvider!.startMotionUpdates()
    }
    
    func setupCamera() {
        view.setPointOfView(to: player.cameraNode)
    }
    
    func movePlayer(to position: SCNVector3) {
        player.move(to: position)
    }
}
