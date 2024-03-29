//
//  AppDelegate.swift
//  home_work_23
//
//  Created by Natalia Drozd on 19.06.22.
//

import UIKit
import GoogleMaps
import RealmSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let value = Bundle.main.infoDictionary?["Api_Key_Map"] as? String { GMSServices.provideAPIKey(value) }       
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        let config = Realm.Configuration(schemaVersion: 3)
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        
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

