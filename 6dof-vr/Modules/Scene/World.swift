//
//  World.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class World {
    
    private enum Constant {
        enum Arena {
            static let size: (x: Int, y: Int) = (20, 20)
            static let position = SCNVector3(0.0, 0.0, -5.0)
        }
        
        enum Gaze {
            static let seconds: TimeInterval = 2.0
        }
    }
    
    weak var view: VRViewType!
    
    let scene: SCNScene
    
    let player: PlayerNode
    let arena: ArenaNode
    
    private let gazeTimer: GazeTimer
    
    init(scene: SCNScene) {
        self.scene = scene
        
        arena = ArenaNode(xCount: Constant.Arena.size.x, yCount: Constant.Arena.size.x)
        arena.position = Constant.Arena.position
        scene.rootNode.addChildNode(arena)
        
        player = PlayerNode(
            startingPosition: arena.simdConvertPosition(arena.positionFor(x: 0, y: 0)!, to: scene.rootNode),
            camera: VRCameraNode())
        scene.rootNode.addChildNode(player)
        
        gazeTimer = GazeTimer(timeInterval: Constant.Gaze.seconds)
        gazeTimer.delegate = self
        
        EnvironmentBuilder().populate(scene)
        EnvironmentLightingBuilder().addLighting(to: scene)
    }
    
    func setupCamera() {
        view.setPointOfView(to: player.cameraNode)
    }
    
    func movePlayer(by offset: simd_float3) {
        player.move(by: offset)
    }
    
    func updatePlayer(with motion: MotionData) {
        player.updatePosition(with: motion)
    }
    
    func playerGazes(at node: SCNNode?) {
        arena.select(node: node as? ArenaFieldNode)
        gazeTimer.update(withNodeGazedAt: node)
    }
}

extension World: GazeTimerDelegate {
    
    func gazeTimerDidFire(withNode node: SCNNode) {
        if let node = node as? ArenaFieldNode, let nodeArenaPosition = arena.positionFor(node) {
            player.move(to: arena.simdConvertPosition(nodeArenaPosition, to: scene.rootNode), animated: true)
        }
    }
}
