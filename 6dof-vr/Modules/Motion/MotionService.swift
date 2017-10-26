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
    
    static var zero: MotionData = MotionData(position: SCNVector3Zero, orientation: SCNVector3Zero)
    
    let position: SCNVector3
    let orientation: SCNVector3
}

final class MotionService {
    
    enum GatheringMode {
        case threeDoF
        case sixDoF
    }
    
    var onMotionUpdate: ((MotionData) -> Void)?
    
    var mode: GatheringMode = .threeDoF {
        didSet { startMotionUpdates() }
    }
    
    private let orientationService: OrientationService
    private let positionService: PositionService
    
    private (set) var currentPosition = SCNVector3(0.0, 0.0, 0.0)
    private (set) var currentOrientation = SCNVector3(0.0, 0.0, 0.0)
    
    init(orientationService: OrientationService, positionService: PositionService) {
        self.orientationService = orientationService
        self.positionService = positionService
    }
    
    func startMotionUpdates() {
        switch mode {
        case .threeDoF:
            setupOrientationServiceCallback()
            
            orientationService.startOrientationUpdates()
        case .sixDoF:
            setupOrientationServiceCallback()
            setupPositionServiceCallback()
            
            orientationService.startOrientationUpdates()
            positionService.startPositionUpdates()
        }
    }
    
    private func setupOrientationServiceCallback() {
        orientationService.onOrientationUpdate = { [weak self] orientation in
            self?.currentOrientation = orientation
        }
    }
    
    private func setupPositionServiceCallback() {
        positionService.onPositionUpdate = { [weak self] position in
            self?.currentPosition = position
            self?.doMotionUpdate()
        }
    }
    
    private func doMotionUpdate() {
        onMotionUpdate?(.init(position: currentPosition, orientation: currentOrientation))
    }
}
