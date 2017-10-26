//
//  VRViewController.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 22/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import UIKit
import SceneKit

protocol VRViewType: class {
    func setPointOfView(to node: VRCameraNode)
}

final class Player {
    
    private (set) var node: SCNNode
    
    var position: SCNVector3 {
        return userPosition + motionPosition
    }
    var orientation: SCNVector3 {
        return userOrientation + motionOrientation
    }
    
    private var userPosition: SCNVector3
    private var userOrientation: SCNVector3
    
    private var motionPosition = SCNVector3Zero
    private var motionOrientation = SCNVector3Zero
    
    init(startingPosition: SCNVector3, startingOrientation: SCNVector3, node: SCNNode) {
        userPosition = startingPosition
        userOrientation = startingOrientation
        self.node = node
    }
    
    func updateMotion(with motionData: MotionData) {
        motionPosition = motionData.position
        motionOrientation = motionData.orientation
    }
    
    func move(to position: SCNVector3) {
        self.userPosition = position
    }
}

final class VRViewController: UIViewController {
    
    enum Constant {
        enum Distance {
            static let recognizerMultiplier: CGFloat = 0.01
        }
    }
    
    @IBOutlet fileprivate weak var leftSceneView: SCNView!
    @IBOutlet fileprivate weak var rightSceneView: SCNView!
    
    var motionService: MotionService!
    var sceneService: SceneService!
    var player: Player!
    
    private var lastPanTranslation: CGPoint?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(leftSceneView)
        setup(rightSceneView)
        
        sceneService.setupCamera()
        
        setupMotionUpdates()
        
        setupMovementPanRecognizer()
    }
    
    @objc private func pannedView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            lastPanTranslation = translation
        case .changed:
            setUserPositionOffset(with: translation)
        default:
            lastPanTranslation = nil
        }
    }

    private func setup(_ sceneView: SCNView) {
        sceneView.scene = sceneService.scene
        sceneView.preferredFramesPerSecond = 60
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
    }
    
    private func setupMovementPanRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
        view.addGestureRecognizer(recognizer)
    }
    
    private func setupMotionUpdates() {
        motionService.onMotionUpdate = { [weak player, weak sceneService] motion in
            player?.updateMotion(with: motion)
            sceneService?.updated(userPosition: motion.position)
            sceneService?.updated(userOrientation: motion.orientation)
        }
        
        motionService.mode = .sixDoF
        
        motionService.startMotionUpdates()
    }
    
    private func setUserPositionOffset(with translation: CGPoint) {
        guard let lastPanTranslation = lastPanTranslation else {
            return
        }
        
//        userPositionService.positionOffset =
//            userPositionService.positionOffset
//            + SCNVector3(
//                (lastPanTranslation.x - translation.x) * Constant.Distance.recognizerMultiplier,
//                0.0,
//                (lastPanTranslation.y - translation.y) * Constant.Distance.recognizerMultiplier)
        
        self.lastPanTranslation = translation
    }
}

extension VRViewController: VRViewType {
    
    func setPointOfView(to node: VRCameraNode) {
        leftSceneView.pointOfView = node.leftNode
        rightSceneView.pointOfView = node.rightNode
    }
}
