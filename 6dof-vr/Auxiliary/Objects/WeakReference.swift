//
//  WeakReference.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 30/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation

struct WeakReference<T: AnyObject> {
    
    weak var referee: T?
    
    init(_ referee: T) {
        self.referee = referee
    }
}
