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
            static let size: Float = 1.0
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
                    height: CGFloat.random(lowerLimit: 0.1, upperLimit: 4.0),
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

        return simd_float3(node.simdPosition.x, maxY, node.simdPosition.z)
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
