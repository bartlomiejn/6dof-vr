//
//  MotionService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 25/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import SceneKit

struct MotionData {
    
    static var zero: MotionData = MotionData(position: SCNVector3Zero, rotation: simd_float4())
    
    let position: SCNVector3
    let rotation: simd_float4
}

protocol MotionDataProvider: class {
    var onMotionUpdate: ((MotionData) -> Void)? { get set }
    func startMotionUpdates()
}

final class MotionService: MotionDataProvider {
    
    enum GatheringMode {
        case threeDoF
        case sixDoF
    }
    
    var onMotionUpdate: ((MotionData) -> Void)?
    
    var mode: GatheringMode = .sixDoF {
        didSet { startMotionUpdates() }
    }
    
    private let rotationService: RotationService
    private let positionService: PositionService
    
    private (set) var currentPosition = SCNVector3Zero
    private (set) var currentRotation = simd_float4()
    
    init(rotationService: RotationService, positionService: PositionService) {
        self.rotationService = rotationService
        self.positionService = positionService
        
        setupOrientationServiceCallback()
        setupPositionServiceCallback()
    }
    
    func startMotionUpdates() {
        switch mode {
        case .threeDoF:
            rotationService.startRotationUpdates()
        case .sixDoF:
            rotationService.startRotationUpdates()
            positionService.startPositionUpdates()
        }
    }
    
    private func setupOrientationServiceCallback() {
        rotationService.onRotationUpdate = { [weak self] rotation in
            self?.currentRotation = rotation
            self?.doMotionUpdate()
        }
    }
    
    private func setupPositionServiceCallback() {
        positionService.onPositionUpdate = { [weak self] position in
            self?.currentPosition = position
            self?.doMotionUpdate()
        }
    }
    
    private func doMotionUpdate() {
        onMotionUpdate?(.init(position: currentPosition, rotation: currentRotation))
    }
}
