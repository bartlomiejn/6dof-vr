//
//  ArenaNode.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 30/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class ArenaNode: SCNNode {
    
    private enum Constant {
        enum Dimension {
            static let size: Float = 1.6
        }
    }
    
    private (set) var nodes = [[WeakReference<ArenaFieldNode>]]()
    
    private (set) weak var selectedNode: ArenaFieldNode?
    
    init(xCount: Int, yCount: Int) {
        super.init()
        
        for ix in 0..<xCount {
            nodes.append([])
            
            for iy in 0..<yCount {
                let field = ArenaFieldNode(
                    width: CGFloat(Constant.Dimension.size),
                    height: CGFloat.random(lowerLimit: 6.0, upperLimit: 10.0),
                    length: CGFloat(Constant.Dimension.size))

                field.simdPosition = simd_float3(
                    Float(ix) * Constant.Dimension.size,
                    0.0,
                    -Float(iy) * Constant.Dimension.size)
                
                addChildNode(field)
                nodes[ix].append(WeakReference(field))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func positionFor(x: Int, y: Int) -> simd_float3? {
        guard x < nodes.count,
              y < nodes[x].count,
              let node = nodes[x][y].referee,
              let maxY = node.geometry?.boundingBox.max.y else {
            return nil
        }
        let mat = simd_float3(node.simdPosition.x, maxY * 2, node.simdPosition.z)
        return mat
    }
    
    func positionFor(_ node: ArenaFieldNode) -> simd_float3? {
        // TODO: Replace this awful pyramid with mapping of local position to array offset
        
        for (ix, weakRefArray) in nodes.enumerated() {
            for (iy, weakNode) in weakRefArray.enumerated() {
                if let testedNode = weakNode.referee, node === testedNode {
                    return positionFor(x: ix, y: iy)
                }
            }
        }
        
        return nil
    }
    
    func select(node: ArenaFieldNode?) {
        guard let node = node else {
            selectedNode?.set(isHighlighted: false)
            return
        }
        
        if let selectedNode = selectedNode, selectedNode === node {
            return
        }
        
        selectedNode?.set(isHighlighted: false)
        node.set(isHighlighted: true)
        selectedNode = node
    }
}
