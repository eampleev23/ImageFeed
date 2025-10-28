//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private enum SplashConstants {
        static let logoImageName: String = "logo_of_unsplash"
    }
    
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: SplashConstants.logoImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = YPColors.black
        view.addSubview(logoImageView) // ДОБАВЛЕНО: Добавляем imageView на view
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(false, animated: false)
            navigationController.pushViewController(authViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: authViewController)
            navigationController.navigationBar.isHidden = false
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = navigationController
                })
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[SplashViewController, didAuthenticate]: ошибка - токен не найден")
            return
        }
        vc.dismiss(animated: true)
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(
            OAuth2TokenStorage.shared.token ?? "") { [weak self] (result: Result<Profile, Error>) in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else {
                    print("[SplashViewController, fetchProfile]: ошибка - self освобожден")
                    return
                }
                switch result {
                case let .success(profile):
                    print("[SplashViewController, fetchProfile]: профиль успешно загружен, profile.userName: \(profile.userName)")
                    ProfileImageService.shared.fetchProfileImageURL(
                        username: profile.userName
                    ){ result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                //                                self.switchToTabBarController()
                                print("[SplashViewController, fetchProfile, ProfileImageService.shared.fetchProfileImageURL]: успешная загрузка аватара")
                            case .failure(let error):
                                print("[SplashViewController, fetchProfile, ProfileImageService.shared.fetchProfileImageURL]: ошибка загрузки аватара - \(error)")
                                //                                self.switchToTabBarController()
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
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            }, completion: { success in
                if success {
                    print("[SplashViewController, switchToTabBarController]: успешно переключились на TabBarController")
                } else {
                    print("[SplashViewController, switchToTabBarController]: ошибка анимации перехода")
                }
            })
        }
    }
}
