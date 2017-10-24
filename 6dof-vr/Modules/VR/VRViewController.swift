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
    func setPointOfView(leftCameraNode: SCNNode, rightCameraNode: SCNNode)
}

final class VRViewController: UIViewController {
    
    enum Constant {
        enum Distance {
            static let recognizerMultiplier: CGFloat = 0.01
        }
    }
    
    @IBOutlet fileprivate weak var leftSceneView: SCNView!
    @IBOutlet fileprivate weak var rightSceneView: SCNView!
    
    var userOrientationService: UserOrientationService!
    var userPositionService: UserPositionService!
    var sceneService: SceneService!
    
    private var lastPanTranslation: CGPoint?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(leftSceneView)
        setup(rightSceneView)
        
        sceneService.setupScene()
        
        setupMovementPanGestureRecognizer()
        setupPositionUpdates()
        setupOrientationUpdates()
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
    
    private func setupMovementPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
        view.addGestureRecognizer(recognizer)
    }
    
    private func setupPositionUpdates() {
        userPositionService.onPositionUpdate = { [weak sceneService] position in
            sceneService?.updated(userPosition: position)
        }
        
        userPositionService.startPositionUpdates()
    }
    
    private func setupOrientationUpdates() {
        userOrientationService.onOrientationUpdate = { [weak sceneService] eulerAnglesMatrix in
            sceneService?.updated(userOrientation: eulerAnglesMatrix)
        }
        
        userOrientationService.startOrientationUpdates()
    }
    
    private func setUserPositionOffset(with translation: CGPoint) {
        guard let lastPanTranslation = lastPanTranslation else {
            return
        }
        
        userPositionService.positionOffset =
            userPositionService.positionOffset
            + SCNVector3(
                (lastPanTranslation.x - translation.x) * Constant.Distance.recognizerMultiplier,
                0.0,
                (lastPanTranslation.y - translation.y) * Constant.Distance.recognizerMultiplier)
        
        self.lastPanTranslation = translation
    }
}

extension VRViewController: VRViewType {
    
    func setPointOfView(leftCameraNode: SCNNode, rightCameraNode: SCNNode) {
        leftSceneView.pointOfView = leftCameraNode
        rightSceneView.pointOfView = rightCameraNode
    }
}
