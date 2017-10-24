//
//  AppDelegate.swift
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 22/10/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private enum Constant {
        enum Storyboard {
            static let scene = "Scene"
        }
    }
    
    var window: UIWindow?
    
    private var injectionService = AppInjectionService()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let storybard = UIStoryboard(name: Constant.Storyboard.scene, bundle: .main)
        let controller = storybard.instantiateInitialViewController() as? VRViewController
     
        injectionService.injectDependencies(into: controller)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        return true
    }
}

