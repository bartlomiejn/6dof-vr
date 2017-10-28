//
//  simd_quatf+AxisAngle.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 28/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import CoreMotion
import simd

extension simd_quatf {
    
    init(_ quat: CMQuaternion) {
        self.init(ix: Float(quat.x), iy: Float(quat.y), iz: Float(quat.z), r: Float(quat.w))
    }
    
    static func fromAxisAngle(_ axisAngle: simd_float4) -> simd_quatf {
        return .init(
            ix: axisAngle.x * sin(axisAngle.w / 2.0),
            iy: axisAngle.y * sin(axisAngle.w / 2.0),
            iz: axisAngle.z * sin(axisAngle.w / 2.0),
            r: cos(axisAngle.w / 2.0))
    }
}
