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
            static let interpupilary = 0.066 // Distance between eyes in meters
        }
    }
    
    @IBOutlet private weak var leftSceneView: SCNView!
    @IBOutlet private weak var rightSceneView: SCNView!
    
    private let motionManager = CMMotionManager()
    private let configuration = ARWorldTrackingConfiguration()
    
    private let scene = SCNScene()
    
    private let leftCamera = SCNCamera()
    private let rightCamera = SCNCamera()
    private let leftCameraNode = SCNNode()
    private let rightCameraNode = SCNNode()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(leftSceneView)
        setup(rightSceneView)
        setupSceneGeometry()
        setupPointOfView()
        setupMotionUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setSceneViewPlaying(to: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        setSceneViewPlaying(to: false)
    }

    private func setup(_ sceneView: SCNView) {
        sceneView.scene = scene
        sceneView.preferredFramesPerSecond = 120
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func setupSceneGeometry() {
        setupBoxNode()
        setupPlaneNode()
    }
    
    private func setupBoxNode() {
        let box = SCNNode(geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.0))
        
        box.position = SCNVector3(0.2, 0.0, -4.0)
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        scene.rootNode.addChildNode(box)
    }
    
    private func setupPlaneNode() {
        let plane = SCNNode(geometry: SCNPlane(width: 50.0, height: 50.0))
        
        plane.position = SCNVector3(0.0, -0.5, 0.0)
        plane.eulerAngles = SCNVector3(90.degreesToRadians, 0.0, 0.0)
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        plane.geometry?.firstMaterial?.isDoubleSided = true
        
        scene.rootNode.addChildNode(plane)
    }
    
    private func setupPointOfView() {
        leftCameraNode.camera = leftCamera
        rightCameraNode.camera = rightCamera
        
        leftCameraNode.position = SCNVector3(-Constant.Distance.interpupilary / 2.0, 1.75, 0.0)
        rightCameraNode.position = SCNVector3(Constant.Distance.interpupilary / 2.0, 1.75, 0.0)
        
        scene.rootNode.addChildNode(leftCameraNode)
        scene.rootNode.addChildNode(rightCameraNode)
        
        leftSceneView.pointOfView = leftCameraNode
        rightSceneView.pointOfView = rightCameraNode
    }
    
    private func setupMotionUpdates() {
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
    
    private func setSceneViewPlaying(to isPlaying: Bool) {
        leftSceneView.isPlaying = isPlaying
        rightSceneView.isPlaying = isPlaying
    }
}

extension VRViewController: SCNSceneRendererDelegate {
    
}

extension VRViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }
    
    private func currentCameraPosition() -> SCNVector3? {
        guard let pov = leftSceneView.pointOfView else {
            return nil
        }
        
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        return orientation + location
    }
}

extension VRViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {

    }
}


func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
