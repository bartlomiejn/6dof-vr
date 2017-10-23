//
//  MRViewController.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 22/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion

final class VRViewController: UIViewController {
    
    private enum Constant {
        enum Distance {
            static let interpupilary: Double = 0.066 // Distance between eyes in meters
        }
    }
    
    @IBOutlet private weak var leftSceneView: SCNView!
    @IBOutlet private weak var rightSceneView: SCNView!
    
    private let session = ARSession()
    private let configuration = ARWorldTrackingConfiguration()
    
    private let motionManager = CMMotionManager()
    
    private let scene = SCNScene()
    
    private let leftCamera = SCNCamera()
    private let rightCamera = SCNCamera()
    private let leftCameraNode = SCNNode()
    private let rightCameraNode = SCNNode()
    
    private var viewportPosition = SCNVector3(0.0, 0.0, 0.0)
    private var lastPanTranslation: CGPoint?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera(leftCamera)
        setupCamera(rightCamera)
        
        setup(leftSceneView)
        setup(rightSceneView)
        
        addBoxNodes(count: 40)
        addPlaneNode()
        
        setupPointOfViewNodes()
        setupPanGestureRecognizer()
        
        startARSession()
        startMotionUpdates()
    }
    
    private func setupCamera(_ camera: SCNCamera) {
        camera.fieldOfView = 110.0
        camera.zNear = 0.1
        camera.zFar = 100.0
    }

    private func setup(_ sceneView: SCNView) {
        sceneView.scene = scene
        sceneView.preferredFramesPerSecond = 60
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
        sceneView.isUserInteractionEnabled = true
    }

    private func addBoxNodes(count: Int) {
        for _ in 0..<count {
            let box = SCNNode(geometry:
                SCNBox(
                    width: random(lowerLimit: 0.2, upperLimit: 1.0),
                    height: random(lowerLimit: 0.5, upperLimit: 6.0),
                    length: random(lowerLimit: 0.2, upperLimit: 1.0),
                    chamferRadius: 0.0))
            
            box.position = SCNVector3(
                random(lowerLimit: -10.0, upperLimit: 10.0),
                0.0,
                random(lowerLimit: -10.0, upperLimit: -1.0))
            box.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            
            scene.rootNode.addChildNode(box)
        }
    }

    private func addPlaneNode() {
        let plane = SCNNode(geometry: SCNPlane(width: 50.0, height: 50.0))
        
        plane.position = SCNVector3(0.0, -0.5, 0.0)
        plane.eulerAngles = SCNVector3(90.degreesToRadians, 0.0, 0.0)
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        plane.geometry?.firstMaterial?.isDoubleSided = true
        
        scene.rootNode.addChildNode(plane)
    }
    
    private func setupPointOfViewNodes() {
        leftCameraNode.camera = leftCamera
        rightCameraNode.camera = rightCamera
        
        leftCameraNode.position = SCNVector3(-Constant.Distance.interpupilary / 2.0, 1.75, 0.0)
        rightCameraNode.position = SCNVector3(Constant.Distance.interpupilary / 2.0, 1.75, 0.0)
        
        scene.rootNode.addChildNode(leftCameraNode)
        scene.rootNode.addChildNode(rightCameraNode)
        
        leftSceneView.pointOfView = leftCameraNode
        rightSceneView.pointOfView = rightCameraNode
    }
    
    private func setupPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func pannedView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        
        switch recognizer.state {
            case .began:
                lastPanTranslation = translation
            case .changed:
                guard let lastPanTranslation = lastPanTranslation else {
                    return
                }
                
                viewportPosition = viewportPosition
                    + SCNVector3(
                        (lastPanTranslation.x - translation.x * 0.02),
                        0.0,
                        (lastPanTranslation.y - translation.y) * 0.02)
                
                self.lastPanTranslation = translation
            default:
                lastPanTranslation = nil
        }
    }
    
    private func startARSession() {
        session.delegate = self
        session.run(configuration)
    }
    
    private func startMotionUpdates() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 120.0
        
        guard motionManager.isDeviceMotionAvailable else {
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak leftCameraNode, weak rightCameraNode] deviceMotion, error in

            leftCameraNode?.eulerAngles = SCNVector3(
                -Float((deviceMotion?.attitude.roll)!) - (Float.pi / 2.0),
                Float((deviceMotion?.attitude.yaw)!),
                -Float((deviceMotion?.attitude.pitch)!)
            )
            rightCameraNode?.eulerAngles = SCNVector3(
                -Float((deviceMotion?.attitude.roll)!) - (Float.pi / 2.0),
                Float((deviceMotion?.attitude.yaw)!),
                -Float((deviceMotion?.attitude.pitch)!)
            )
        }
    }
}

extension VRViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let translationColumn = frame.camera.transform.columns.3
        
        leftCameraNode.position =
            SCNVector3(
                translationColumn.x - Float(Constant.Distance.interpupilary / 2.0),
                translationColumn.y,
                translationColumn.z)
            + viewportPosition
        rightCameraNode.position =
            SCNVector3(
                translationColumn.x + Float(Constant.Distance.interpupilary / 2.0),
                translationColumn.y,
                translationColumn.z)
            + viewportPosition
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

func random(lowerLimit: CGFloat, upperLimit: CGFloat) -> CGFloat {
    return lowerLimit + (upperLimit - lowerLimit) * (CGFloat(arc4random()) / CGFloat(UInt32.max))
}
