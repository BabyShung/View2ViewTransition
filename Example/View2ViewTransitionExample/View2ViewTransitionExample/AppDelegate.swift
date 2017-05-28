//
//  AppDelegate.swift
//  View2ViewTransitionExample
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
      
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = MenuViewController()
        self.window?.makeKeyAndVisible()

        return true
    }
}

