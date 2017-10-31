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
            static let recognizerMultiplier: Float = 0.01
        }
    }
    
    private weak var leftSceneView: SCNView!
    private weak var rightSceneView: SCNView!
    
    var motionService: MotionService!
    var world: World!
    
    private var lastPanTranslation: CGPoint = .zero
    private var lastSliderValue: Float = 0.0
    private var lastPanTranslationOffset: CGPoint = .zero
    private var lastSliderOffset: Float = 0.0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let renderingApiKey = SCNView.Option.preferredRenderingAPI.rawValue
        let openGLES2 = NSNumber(value: SCNRenderingAPI.openGLES2.rawValue)
        
        leftSceneView = SCNView(frame: .zero, options: [renderingApiKey: openGLES2])
        rightSceneView = SCNView(frame: .zero, options: [renderingApiKey: openGLES2])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupCamera() {
        world.setupCamera()
    }
    
    fileprivate func startMotionUpdates() {
        motionService.startMotionUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(leftSceneView)
        setup(rightSceneView)
        setupLayout()
        setupCamera()
        setupBarrelDistortion()
        setupMovementPanRecognizer()
        startMotionUpdates()
    }
    
    @IBAction func heightSliderValueChanged(_ sender: UISlider) {
        lastSliderOffset = sender.value - lastSliderValue
        lastSliderValue = sender.value
        
        world.movePlayer(by: simd_float3(0.0, lastSliderOffset, 0.0))
    }
    
    @objc private func pannedView(recognizer: UIPanGestureRecognizer) {
        let currentTranslation = recognizer.translation(in: view)
        
        switch recognizer.state {
        case .began:
            lastPanTranslation = currentTranslation
        case .changed:
            calculateOffset(from: currentTranslation)
        default:
            lastPanTranslation = .zero
        }
    }
    
    private func setup(_ sceneView: SCNView) {
        sceneView.scene = world.scene
        sceneView.preferredFramesPerSecond = 120
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
        if sceneView === leftSceneView {
            // No need for two delegate calls
            sceneView.delegate = self
        }
        
        view.addSubview(sceneView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            leftSceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            leftSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftSceneView.trailingAnchor.constraint(equalTo: rightSceneView.leadingAnchor),
            leftSceneView.widthAnchor.constraint(equalTo: rightSceneView.widthAnchor),
            rightSceneView.leadingAnchor.constraint(equalTo: leftSceneView.trailingAnchor),
            rightSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            rightSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightSceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    private func setupBarrelDistortion() {
        guard let dictionary = FileLoader().loadDictionary(fromJsonNamed: "barrel_dist"),
              let barrelDistortion = SCNTechnique(dictionary: dictionary) else {
            assertionFailure("Could not load technique dictionary.")
            return
        }
        
        barrelDistortion.setValue(NSNumber(value: 0.9), forKey: "barrel_power")
        
        leftSceneView.technique = barrelDistortion
        rightSceneView.technique = barrelDistortion
    }
    
    private func setupMovementPanRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
        view.addGestureRecognizer(recognizer)
    }
    
    private func calculateOffset(from translation: CGPoint) {
        lastPanTranslationOffset = CGPoint(
            x: lastPanTranslation.x - translation.x,
            y: lastPanTranslation.y - translation.y)
        
        self.lastPanTranslation = translation
        
        world.movePlayer(by:
            simd_float3(
                Float(lastPanTranslationOffset.x) * Constant.Distance.recognizerMultiplier,
                0.0,
                Float(lastPanTranslationOffset.y) * Constant.Distance.recognizerMultiplier))
    }
}

extension VRViewController: VRViewType {
    
    func setPointOfView(to node: VRCameraNode) {
        leftSceneView.pointOfView = node.leftNode
        rightSceneView.pointOfView = node.rightNode
    }
}

extension VRViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.performGazeHitTest()
            self?.updatePlayerMotion()
        }
    }
    
    private func performGazeHitTest() {
        let centerPoint = CGPoint(x: leftSceneView.bounds.width / 2.0, y: leftSceneView.bounds.height / 2.0)
        
        world.playerGazes(at: leftSceneView.hitTest(centerPoint).first?.node)
    }
    
    private func updatePlayerMotion() {
        world.updatePlayer(with: motionService.motionData)
    }
}
