//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by bob on 2021/5/28.
//  Copyright © 2021 rangers. All rights reserved.
//

import UIKit
import FuckKit
import SwiftFuckKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    @Inject<FKLogService> var logger
    @Inject<Dog> var dog
    @Inject<Heater> var heater
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FKSwiftLog.debug("App", "AppLoadService")
        logger?.verbose("Test Log")
        dog?.bark()
        heater?.heat()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

