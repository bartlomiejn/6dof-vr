//
//  SceneService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import SceneKit

final class SceneService {
    
    private enum Constant {
        enum Camera {
            static let nearPlane: Double = 0.1
            static let farPlane: Double = 100.0
            static let fieldOfView: CGFloat = 100.0
        }
        
        enum Distance {
            static let pupillary: CGFloat = 0.066        // Distance between eyes in meters
            static let recognizerMultiplier: CGFloat = 0.01
        }
        
        static let leftEyeTranslation = SCNVector3(-Float(Distance.pupillary / 2.0), 0.0, 0.0)
        static let rightEyeTranslation = SCNVector3(Float(Distance.pupillary / 2.0), 0.0, 0.0)
    }
    
    weak var view: VRViewType!
    
    let scene: SCNScene
    
    private let leftCamera = SCNCamera()
    private let rightCamera = SCNCamera()
    
    private let leftCameraNode = SCNNode()
    private let rightCameraNode = SCNNode()
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    func setupScene() {
        setupCamera(leftCamera)
        setupCamera(rightCamera)
        
        addBoxNodes(count: 200)
        addFloorNode()
        
        addBackground()
        addDirectionalLighting()
        
        setupPointOfViewNodes()
        
        view.setPointOfView(leftCameraNode: leftCameraNode, rightCameraNode: rightCameraNode)
    }
    
    func updated(userPosition: SCNVector3) {
        leftCameraNode.position = userPosition + Constant.leftEyeTranslation
        rightCameraNode.position = userPosition + Constant.rightEyeTranslation
    }
    
    func updated(userOrientation: SCNVector3) {
        leftCameraNode.eulerAngles = userOrientation
        rightCameraNode.eulerAngles = userOrientation
    }
    
    private func setupCamera(_ camera: SCNCamera) {
        camera.zNear = Constant.Camera.nearPlane
        camera.zFar = Constant.Camera.farPlane
        camera.fieldOfView = Constant.Camera.fieldOfView
    }
    
    private func addBoxNodes(count: Int) {
        for _ in 0..<count {
            let randomHeight = CGFloat.random(lowerLimit: 1.0, upperLimit: 20.0)
            let box = SCNNode(geometry:
                SCNBox(
                    width: CGFloat.random(lowerLimit: 0.5, upperLimit: 3.0),
                    height: randomHeight,
                    length: CGFloat.random(lowerLimit: 0.5, upperLimit: 3.0),
                    chamferRadius: 0.0))
            
            box.position = SCNVector3(
                CGFloat.random(lowerLimit: -100.0, upperLimit: 100.0),
                0.0,
                CGFloat.random(lowerLimit: -100.0, upperLimit: 100.0))
            
            box.pivot = SCNMatrix4MakeTranslation(0.0, -Float(randomHeight / 2.0), 0.0)

            box.geometry?.firstMaterial?.lightingModel = .physicallyBased
            box.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            box.geometry?.firstMaterial?.roughness.contents = UIColor.darkGray
            box.geometry?.firstMaterial?.metalness.contents = UIColor.darkGray
            
            scene.rootNode.addChildNode(box)
        }
    }
    
    private func addFloorNode() {
        let floor = SCNFloor()
        
        floor.reflectivity = 0.3
        
        let plane = SCNNode(geometry: floor)
        
        plane.position = SCNVector3(0.0, 0.0, 0.0)
        plane.geometry?.firstMaterial?.lightingModel = .physicallyBased
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
        plane.geometry?.firstMaterial?.roughness.contents = UIColor.darkGray
        plane.geometry?.firstMaterial?.metalness.contents = UIColor.darkGray
        
        scene.rootNode.addChildNode(plane)
    }
    
    private func addBackground() {
        let backgroundImage = UIImage(named: "sky_map")
        
        scene.background.contents = backgroundImage
        
        scene.lightingEnvironment.contents = backgroundImage
        scene.lightingEnvironment.intensity = 3.0
    }
    
    private func addDirectionalLighting() {
        let light = SCNLight()
        
        light.type = .directional
        light.castsShadow = true
        
        let node = SCNNode()
        
        node.light = light
        node.position = SCNVector3(0.0, 0.0, 0.0)
        node.eulerAngles = SCNVector3(-(Float.pi / 4.0), -Float.pi / 2.0, 0.0)
        
        scene.rootNode.addChildNode(node)
    }
    
    private func setupPointOfViewNodes() {
        leftCameraNode.camera = leftCamera
        rightCameraNode.camera = rightCamera
        
        leftCameraNode.position = SCNVector3(-Constant.Distance.pupillary / 2.0, 1.75, 0.0)
        rightCameraNode.position = SCNVector3(Constant.Distance.pupillary / 2.0, 1.75, 0.0)
        
        scene.rootNode.addChildNode(leftCameraNode)
        scene.rootNode.addChildNode(rightCameraNode)
    }
}
