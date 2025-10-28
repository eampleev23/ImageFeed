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
            //Пользователь авторизован
            fetchProfile(token: token)
        } else {
            //Пользователь не авторизован
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
    
    // ДОБАВЛЕНО: Новый метод для показа экрана авторизации программно
    private func showAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        print("func didAuthenticate(_ vc: AuthViewController) in SplashViewController")
        guard let token = OAuth2TokenStorage.shared.token else { return }
        vc.dismiss(animated: true)
        fetchProfile(token: token)
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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        tabBarController.view.backgroundColor = .ypBlack
        window.rootViewController = tabBarController
    }
}
