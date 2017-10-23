//
//  SceneViewController.swift
//  Objects
//
//  Created by Bartłomiej Nowak on 22/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import UIKit
import ARKit

fileprivate enum Tracking {
    enum State {
        case unavailable
        case limited
        case available
    }
}

fileprivate enum Measuring {
    enum State {
        case firstNode
        case measuring
        case nextNode
    }
}

enum Error {
    struct MissingScene: Swift.Error {}
    struct MissingNodeInScene: Swift.Error {}
}

final class SceneViewController: UIViewController {
    
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet private weak var actionButton: UIButton!
    
    var presenter: SceneViewPresenter!
    
    private var trackingState: Tracking.State = .unavailable
    private var measuringState: Measuring.State = .firstNode
    
    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        
        setupConfiguration()
        setupSceneViewProperties()
        setupSceneViewGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction private func actionTapped(_ sender: Any) {
        performAction()
    }
    
    @objc private func tappedView(recognizer: UITapGestureRecognizer) {
        addSelectedItem(at: recognizer.location(in: sceneView))
    }
    
    @objc private func pinchedView(recognizer: UIPinchGestureRecognizer) {
        scaleView(at: recognizer.location(in: sceneView), using: recognizer)
    }
    
    private func setupConfiguration() {
        configuration.planeDetection = .horizontal
    }
    
    private func setupSceneViewProperties() {
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func setupSceneViewGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        sceneView.addGestureRecognizer(tapRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        sceneView.addGestureRecognizer(pinchRecognizer)
    }
    
    private func performAction() {
        switch measuringState {
        case .firstNode:
            break
        case .measuring:
            break
        case .nextNode:
            break
        }
    }
    
    private func addBoxWithPhysics(inFrontOf cameraTransform: SCNMatrix4) {
        guard let cameraPosition = currentCameraPosition() else {
            return
        }
        
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0))
        
        box.position = cameraPosition
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        box.physicsBody = .dynamic()
        box.physicsBody!.friction = 2.0
        
        sceneView.scene.rootNode.addChildNode(box)
    }
    
    private func addSelectedItem(at location: CGPoint) {
        guard let planeHit = sceneView.hitTest(location, types: .existingPlaneUsingExtent).first else {
            return
        }
        
        do {
            let worldPosition = planeHit.worldTransform.columns.3
            let vase = try vaseNode(at: SCNVector3(worldPosition.x, worldPosition.y, worldPosition.z))
            sceneView.scene.rootNode.addChildNode(vase)
        } catch {}
    }
    
    private func vaseNode(at position: SCNVector3) throws -> SCNNode {
        guard let scene = SCNScene(named: "Media.scnassets/Vase.scn") else {
            throw Error.MissingScene()
        }
        
        guard let node = scene.rootNode.childNode(withName: "Vase", recursively: false) else {
            throw Error.MissingNodeInScene()
        }
        
        node.position = position
        
        return node
    }
    
    private func scaleView(at location: CGPoint, using recognizer: UIPinchGestureRecognizer) {
        guard let result = sceneView.hitTest(location).first else {
            return
        }
        
        let scale = SCNAction.scale(by: recognizer.scale, duration: 0.0)
        result.node.runAction(scale)
        recognizer.scale = 1.0
    }
}

extension SceneViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
            case .notAvailable:
                trackingState = .unavailable
            case .limited:
                trackingState = .limited
            case .normal:
                trackingState = .available
        }
    }
}

extension SceneViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        let middlePoint = CGPoint(x: sceneView.bounds.width / 2.0, y: sceneView.bounds.height / 2.0)
        
        guard let planeHitResult = sceneView.hitTest(middlePoint, types: .existingPlane).first else {
            return
        }
        
        let ringShape = SCNShape(path: ringBezierPath(outerRadius: 0.04, innerRadius: 0.035), extrusionDepth: 0.0)
        let worldPosition = planeHitResult.worldTransform.columns.3

        let node = SCNNode(geometry: ringShape)
        node.position = SCNVector3(worldPosition.x, worldPosition.y, worldPosition.z)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func ringBezierPath(outerRadius: CGFloat, innerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        
        
        return path
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        node.addChildNode(planeNode(at: anchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        removeExistingPlaneNode(from: node)
        node.addChildNode(planeNode(at: anchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        
        removeExistingPlaneNode(from: node)
    }
    
    private func planeNode(at anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let node = SCNNode(geometry: plane)
        
        node.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        node.eulerAngles = SCNVector3(90.degreesToRadians, 0.0, 0.0)
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
        node.geometry?.firstMaterial?.isDoubleSided = true
        
        node.physicsBody = .static()
        
        return node
    }
    
    private func currentCameraPosition() -> SCNVector3? {
        guard let pov = sceneView.pointOfView else {
            return nil
        }
        
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        return orientation + location
    }
    
    private func removeExistingPlaneNode(from anchorNode: SCNNode) {
        anchorNode.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
