//
//  CGFloat+Random.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    static func random(lowerLimit: CGFloat, upperLimit: CGFloat) -> CGFloat {
        return lowerLimit + (upperLimit - lowerLimit) * (CGFloat(arc4random()) / CGFloat(UInt32.max))
    }
}
