//
//  SceneDelegate.swift
//  Manga
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController.make()
        window?.makeKeyAndVisible()
    }
}
