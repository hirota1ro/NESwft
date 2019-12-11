//
//  SceneDelegate.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2019/12/11.
//  Copyright © 2019 HIROTA Ichiro. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let srcURL = URLContexts.first?.url else {
            return
        }
        print("srcURL=\(srcURL)")
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\(#function) no document directory")
            return
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
    }
}
