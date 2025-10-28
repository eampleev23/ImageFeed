//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 09.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene as! UIWindowScene)
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
    }
}

