//
//  ArenaFieldNode.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 30/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import SceneKit

final class ArenaFieldNode: SCNNode {
    
    private enum Constant {
        enum Material {
            enum Normal {
                static let diffuse = UIColor.lightGray
                static let roughness = UIColor.darkGray
                static let metalness = UIColor.darkGray
            }
            enum Highlighted {
                static let diffuse = UIColor.red
                static let roughness = UIColor.lightGray
                static let metalness = UIColor.lightGray
            }
        }
        
        enum Animation {
            static let length: TimeInterval =  0.1
        }
    }
    
    init(width: CGFloat, height: CGFloat, length: CGFloat) {
        super.init()
        
        geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
        pivot = SCNMatrix4MakeTranslation(0.0, -Float(height / 2.0), 0.0)
        
        geometry?.firstMaterial?.lightingModel = .physicallyBased
        
        set(isHighlighted: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(isHighlighted: Bool) {
        geometry?.firstMaterial?.diffuse.contents = isHighlighted
            ? Constant.Material.Highlighted.diffuse
            : Constant.Material.Normal.diffuse
        geometry?.firstMaterial?.roughness.contents = isHighlighted
            ? Constant.Material.Highlighted.roughness
            : Constant.Material.Normal.roughness
        geometry?.firstMaterial?.metalness.contents = isHighlighted
            ? Constant.Material.Highlighted.metalness
            : Constant.Material.Normal.metalness
    }
}
