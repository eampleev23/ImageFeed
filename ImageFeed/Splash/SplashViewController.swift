//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private enum Constants {
        static let logoImageName: String = "logo_of_unsplash"
    }
    
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Constants.logoImageName))
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
            self.showErrorAlert(error: AppError.tokenValidationFailed)
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
                    self.fetchProfileImage(username: profile.userName)
                    
                case .failure (let error):
                    print("[SplashViewController, fetchProfile, profileService.fetchProfile]: ошибка загрузки профиля - \(error)")
                    self.handleProfileError(error)
                    break
                }
            }
    }
    
    private func fetchProfileImage(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("[SplashViewController]: успешная загрузка аватара")
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("[SplashViewController]: ошибка загрузки аватара - \(error)")
                    // Показываем ошибку, но все равно переходим в приложение
                    self?.showErrorAlert(error: error)
                    self?.switchToTabBarController()
                }
            }
        }
    }
    
    private func handleProfileError(_ error: Error) {
        // Преобразуем ошибку в AppError если нужно
        let appError: AppError
        if let existingAppError = error as? AppError {
            appError = existingAppError
        } else {
            appError = AppError.profileLoadFailed
        }
        
        // Показываем alert с возможностью повтора
        self.showRetryAlert(error: appError) { [weak self] in
            if let token = self?.storage.token {
                self?.fetchProfile(token: token)
            } else {
                self?.showAuthViewController()
            }
        }
    }
    
    private func showRetryAlert(error: Error, retryHandler: @escaping () -> Void) {
        let title: String
        let message: String
        
        if let appError = error as? AppError {
            title = "Ошибка загрузки"
            message = appError.errorDescription ?? "Не удалось загрузить данные"
        } else {
            title = "Ошибка"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            retryHandler()
        })
        
        alert.addAction(UIAlertAction(title: "Выйти", style: .cancel) { [weak self] _ in
            self?.showAuthViewController()
        })
        
        present(alert, animated: true)
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            }, completion: { success in
                if !success {
                    print("[SplashViewController, switchToTabBarController]: ошибка анимации перехода")
                }
            })
        }
    }
    private func showErrorAlert(error: Error) {
        let title: String
        let message: String
        let recoveryMessage: String?
        
        if let appError = error as? AppError {
            title = "Ошибка"
            message = appError.errorDescription ?? "Произошла ошибка"
            recoveryMessage = appError.recoverySuggestion
        } else {
            title = "Что-то пошло не так"
            message = error.localizedDescription
            recoveryMessage = "Попробуйте еще раз"
        }
        
        let fullMessage: String
        if let recovery = recoveryMessage {
            fullMessage = "\(message)\n\n\(recovery)"
        } else {
            fullMessage = message
        }
        
        let alert = UIAlertController(
            title: title,
            message: fullMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
