//
//  GazeTimer.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 30/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

protocol GazeTimerDelegate: class {
    func gazeTimerDidFire(withNode node: SCNNode)
}

final class GazeTimer {
    
    weak var delegate: GazeTimerDelegate?
    
    private weak var nodeGazed: SCNNode?
    
    private var timer: Timer!
    private let interval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.interval = timeInterval
        self.timer = generateTimer(timeInterval: timeInterval)
    }
    
    func update(withNodeGazedAt node: SCNNode?) {
        guard let node = node else {
            if nodeGazed != nil {
                timer.invalidate()
            }
            return
        }
        
        if nodeGazed !== node {
            reset()
            nodeGazed = node
        }
    }
    
    private func reset() {
        timer.invalidate()
        timer = generateTimer(timeInterval: interval)
    }
    
    private func generateTimer(timeInterval: TimeInterval) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            if let nodeGazed = self?.nodeGazed {
                self?.delegate?.gazeTimerDidFire(withNode: nodeGazed)
                self?.nodeGazed = nil
            }
            
            self?.timer.invalidate()
        }
    }
}
