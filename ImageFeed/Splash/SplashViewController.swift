//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            //TODO:  Пользователь авторизован
        } else {
            //TODO: Пользователь не авторизован
        }
    }
    
}
