//
//  AppDelegate.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/22.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ app: UIApplication, open srcURL: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(#function) no document directory")
            return false
        }
        let name = srcURL.lastPathComponent
        let dstURL = docURL.appendingPathComponent(name)
        do {
            try FileManager.default.moveItem(at: srcURL, to: dstURL)
            print("\(#function) moved from=\(srcURL) to=\(dstURL)")
        } catch let error {
            print("\(#function) error=\(error)")
        }
        NotificationCenter.default.post(name: .needsReload, object: nil)
        return true
    }
}

// MARK: UISceneSession Lifecycle

@available(iOS 13.0, *)
extension AppDelegate {

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

extension Notification.Name {
    static let needsReload = Notification.Name("needsReload")
}
