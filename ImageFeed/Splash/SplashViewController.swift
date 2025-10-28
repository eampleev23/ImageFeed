//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegue"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            //Пользователь авторизован
            fetchProfile(token: token)
            switchToTabBarController()
        } else {
            //Пользователь не авторизован
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим именно на авторизацию
        if segue.identifier == "showAuthenticationScreenSegue" {
            
            // Доберемся до первого контроллера в навигации
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Faild to prepare  for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        print("func didAuthenticate(_ vc: AuthViewController) in SplashViewController")
        guard let token = OAuth2TokenStorage.shared.token else { return }
        vc.dismiss(animated: true)
        fetchProfile(token: token)
        //        switchToTabBarController()
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(
            OAuth2TokenStorage.shared.token ?? "") { [weak self] (result: Result<Profile, Error>) in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                case let .success(profile):
                    ProfileImageService.shared.fetchProfileImageURL(
                        username: profile.userName
                    ){ result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                self.switchToTabBarController()
                            case .failure(let error):
                                print("[SplashViewController, fetchProfile,  ProfileImageService.shared.fetchProfileImageURL]: error: \(error)")
                                self.switchToTabBarController()
                            }
                        }
                    }
                    self.switchToTabBarController()
                case .failure:
                    //TODO: sprint 11
                    break
                }
            }
    }
    
    private func switchToTabBarController(){
        
        // Получаем активную window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаем экземпляр нужного контроллера из Storyboard
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        tabBarController.view.backgroundColor = .ypBlack
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}
