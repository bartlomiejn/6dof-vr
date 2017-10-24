//
//  AppInjectionService.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 24/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import Foundation
import CoreMotion
import ARKit

protocol InjectionService: class {
    typealias Injector = (Any) -> Void
    
    var injectors: [AnyHashable: Injector] { get set }
    
    func addInjector<T>(for type: T, injector: @escaping Injector)
    func injector<T>(for type: T) -> Injector?
}

extension InjectionService {
    
    func addInjector<T>(for type: T, injector: @escaping Injector) {
        injectors[String(reflecting: type)] = injector
    }
    
    func injector<T>(for type: T) -> Injector? {
        return injectors[String(reflecting: type)]
    }
}

final class AppInjectionService: InjectionService {
    
    var injectors: [AnyHashable: Injector] = [:]
    
    private let motionManager = CMMotionManager()
    private let arSession = ARSession()
    
    private let appScene = SCNScene()
    
    init() {
        addInjector(for: VRViewController.self) { [weak motionManager, weak arSession, weak appScene] in
            let controller = ($0 as? VRViewController)
            controller?.userOrientationService = UserOrientationService(motionManager: motionManager!)
            controller?.userPositionService = UserPositionService(session: arSession!)
            controller?.sceneService = SceneService(scene: appScene!)
            controller?.sceneService.view = controller
        }
    }
}
