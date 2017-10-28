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
    
    static var zero: MotionData = MotionData(
        position: SCNVector3Zero,
        axisAngle: SCNVector4Zero)
    
    let position: SCNVector3
    let axisAngle: SCNVector4
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
    
    private let orientationService: OrientationService
    private let positionService: PositionService
    
    private (set) var currentPosition = SCNVector3Zero
    private (set) var currentAxisAngle = SCNVector4Zero
    
    init(orientationService: OrientationService, positionService: PositionService) {
        self.orientationService = orientationService
        self.positionService = positionService
        
        setupOrientationServiceCallback()
        setupPositionServiceCallback()
    }
    
    func startMotionUpdates() {
        switch mode {
        case .threeDoF:
            orientationService.startOrientationUpdates()
        case .sixDoF:
            orientationService.startOrientationUpdates()
            positionService.startPositionUpdates()
        }
    }
    
    private func setupOrientationServiceCallback() {
        orientationService.onAxisAngleUpdate = { [weak self] axisAngle in
            self?.currentAxisAngle = axisAngle
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
        onMotionUpdate?(.init(position: currentPosition, axisAngle: currentAxisAngle))
    }
}
