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

struct InjectorUnavailable: Error {}

protocol InjectionService: class {
    typealias Injector = (Any) -> Void
    
    var injectors: [AnyHashable: Injector] { get set }
    
    func addInjector<T>(for type: T.Type, injector: @escaping Injector)
    func injector<T>(for type: T.Type) -> Injector?
    func injectDependencies<T>(into object: T)
}

extension InjectionService {
    
    func addInjector<T>(for type: T.Type, injector: @escaping Injector) {
        injectors[String(reflecting: type)] = injector
    }
    
    func injector<T>(for type: T.Type) -> Injector? {
        return injectors[String(reflecting: type)]
    }
    
    func injectDependencies<T>(into object: T) {
        if let inject = injectors[String(reflecting: T.self)] {
            inject(object)
        } else {
            assertionFailure("No injector registered for type \(T.self).")
        }
    }
}

final class AppInjectionService: InjectionService {

    var injectors: [AnyHashable: Injector] = [:]
    
    private let motionManager = CMMotionManager()
    private let arSession = ARSession()
    
    private let appScene = SCNScene()
    
    private lazy var orientationService = OrientationService(motionManager: motionManager)
    private lazy var positionService = PositionService(session: arSession)
    
    private lazy var motionService = MotionService(
        orientationService: orientationService,
        positionService: positionService)
    
    init() {
        addInjector(for: VRViewController.self) { [unowned motionService, unowned appScene] in
            let controller = ($0 as? VRViewController)
            
            controller?.motionService = motionService
            controller?.sceneService = SceneService(scene: appScene)
            controller?.sceneService.view = controller
        }
    }
}
