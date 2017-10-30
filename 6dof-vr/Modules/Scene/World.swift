//
//  World.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class GazeTimer {
    
    protocol Delegate {
        func gazeTimerDidFire(withNode node: SCNNode)
    }
    
    weak var delegate: Delegate?
    
    private weak var nodeGazed: SCNNode?
    
    private var timer: Timer
    
    init(time: TimeInterval) {
        self.timer = generateTimer(timeInterval: time)
    }
    
    func update(withNodeGazedAt node: SCNNode?) {
        guard let node = node else {
            timer.invalidate()
            return
        }
        
        if selectedNode !== nodeGazed {
            reset()
            selectedNode = nodeGazed
        }
    }
    
    private func reset() {
        timer.invalidate()
        timer = generateTimer()
    }
    
    private func generateTimer(timeInterval: TimeInterval) -> Timer {
        return Timer(timeInterval: timeInterval, repeats: false) { [weak self] _ in
            if let nodeGazed = nodeGazed {
                self?.delegate?.gazeTimerDidFire(withNode: nodeGazed)
            }
            
            self?.timer.invalidate()
        }
    }
}

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
        
        EnvironmentBuilder().populate(scene)
        EnvironmentLightingBuilder().addLighting(to: scene)
        
        arena = ArenaNode(xCount: Constant.Arena.size.x, yCount: Constant.Arena.size.x)
        arena.position = Constant.Arena.position
        scene.rootNode.addChildNode(arena)
        
        player = PlayerNode(
            startingPosition: arena.simdConvertPosition(arena.positionFor(x: 0, y: 0)!, to: scene.rootNode),
            camera: VRCameraNode())
        scene.rootNode.addChildNode(player)
        
        gazeTimer = GazeTimer(time: Constant.Gaze.seconds)
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
    
    func
    
    func playerGazes(at node: SCNNode?) {
        arena.select(node: node as? ArenaFieldNode)
        gazeTimer.update(nodeGazed: node)
    }
}

extension World: GazeTimerDelegate {
    
    func gazeTimerDidFire(withNode node: SCNNode) {
        if let node = node as? ArenaFieldNode {
            
        }
    }
}
