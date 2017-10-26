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

final class VRViewController: UIViewController {
    
    enum Constant {
        enum Distance {
            static let recognizerMultiplier: CGFloat = 0.01
        }
    }
    
    @IBOutlet fileprivate weak var leftSceneView: SCNView!
    @IBOutlet fileprivate weak var rightSceneView: SCNView!
    
    var motionService: MotionService!
    var world: World!
    
    private var lastPanTranslation: CGPoint?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(leftSceneView)
        setup(rightSceneView)
        
        world.setupCamera()
        world.setupMotionProvider(with: motionService)
        
        setupMovementPanRecognizer()
    }
    
    @objc private func pannedView(recognizer: UIPanGestureRecognizer) {
        let currentTranslation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            lastPanTranslation = currentTranslation
        case .changed:
            movePlayer(with: currentTranslation)
        default:
            lastPanTranslation = nil
        }
    }

    private func setup(_ sceneView: SCNView) {
        sceneView.scene = world.scene
        sceneView.preferredFramesPerSecond = 60
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
    }
    
    private func setupMovementPanRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
        view.addGestureRecognizer(recognizer)
    }
    
    private func movePlayer(with translation: CGPoint) {
        guard let lastPanTranslation = lastPanTranslation else {
            return
        }
        
        world.movePlayer(to:
            SCNVector3(
                (lastPanTranslation.x - translation.x) * Constant.Distance.recognizerMultiplier,
                0.0,
                (lastPanTranslation.y - translation.y) * Constant.Distance.recognizerMultiplier))
        
        self.lastPanTranslation = translation
    }
}

extension VRViewController: VRViewType {
    
    func setPointOfView(to node: VRCameraNode) {
        leftSceneView.pointOfView = node.leftNode
        rightSceneView.pointOfView = node.rightNode
    }
}
