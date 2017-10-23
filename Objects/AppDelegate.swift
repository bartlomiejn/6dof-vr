//
//  AppDelegate.swift
//  Objects
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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storybard = UIStoryboard(name: Constant.Storyboard.scene, bundle: .main)
        let controller = storybard.instantiateInitialViewController() as? SceneViewController
        
        controller?.presenter = SceneViewPresenter()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        
        return true
    }
}

