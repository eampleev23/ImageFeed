//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private enum AuthConstants {
        static let translatesAutoresizingMaskIntoConstraints: Bool = false
        static let logoImageViewImageName: String = "logo_of_unsplash"
        static let loginUIButtonText: String = "Войти"
        static let loginUIButtonFontSize: CGFloat = 17
        static let loginUIButtonCornerRadius: CGFloat = 16
        static let loginUIButtonMasksToBounds: Bool = true
        static let loginUIButtonLeadingAnchor: CGFloat = 16
        static let loginUIButtonTrailingAnchor: CGFloat = -16
        static let loginUIButtonHeightAnchor: CGFloat = 48
        static let loginUIButtonBottomAnchor: CGFloat = -106
    }
    
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: AuthConstants.logoImageViewImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = AuthConstants.translatesAutoresizingMaskIntoConstraints
        return imageView
    }()
    
    private let loginUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.tintColor = YPColors.white
        uiButton.translatesAutoresizingMaskIntoConstraints = AuthConstants.translatesAutoresizingMaskIntoConstraints
        
        uiButton.setTitle(AuthConstants.loginUIButtonText, for: .normal)
        uiButton.titleLabel?.font = UIFont.systemFont(ofSize: AuthConstants.loginUIButtonFontSize, weight: .bold)
        uiButton.setTitleColor(YPColors.black, for: .normal)
        
        uiButton.backgroundColor = YPColors.white
        uiButton.layer.cornerRadius = AuthConstants.loginUIButtonCornerRadius
        uiButton.layer.masksToBounds = AuthConstants.loginUIButtonMasksToBounds
        
        return uiButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        setupButtonTarget()
    }
    
    private func setupView(){
        
        view.backgroundColor = YPColors.black
        view.addSubview(logoImageView)
        view.addSubview(loginUIButton)
    }
    
    @objc
    private func didTapLoginBtn(){
        print("[AuthViewController, didTapLoginBtn]: нажата кнопка входа")
        showWebViewViewController()
    }
    
    private func showWebViewViewController() {
        print("[AuthViewController, showWebViewViewController]: создаем WebViewViewController программно")
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
        print("[AuthViewController, showWebViewViewController]: WebViewViewController показан")
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            
            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            logoImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            
            loginUIButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            loginUIButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: AuthConstants.loginUIButtonLeadingAnchor
            ),
            loginUIButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: AuthConstants.loginUIButtonTrailingAnchor
            ),
            loginUIButton.heightAnchor.constraint(
                equalToConstant: AuthConstants.loginUIButtonHeightAnchor
            ),
            loginUIButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: AuthConstants.loginUIButtonBottomAnchor
            ),
        ])
    }
    
    private func setupButtonTarget() {
        loginUIButton.addTarget(self, action: #selector(didTapLoginBtn), for: .touchUpInside)
    }
}
// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        print("[AuthViewController, webViewViewController(didAuthenticateWithCode)]: получен код авторизации: \(code)")
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                print("[AuthViewController, webViewViewController(didAuthenticateWithCode)]: успешно получен токен: \(token.prefix(10))...")
                DispatchQueue.main.async {
                    self?.switchToTabBarController()
                }
                
            case .failure(let error):
                print("[AuthViewController, webViewViewController(didAuthenticateWithCode)]: ошибка получения токена: \(error.localizedDescription)")
                // Показываем alert с ошибкой
                DispatchQueue.main.async {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        print("[AuthViewController, switchToTabBarController]: переключаемся на TabBarController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("[AuthViewController, switchToTabBarController]: ошибка - не удалось найти window")
            return
        }
        
        let tabBarController = TabBarController()
        
        // ✅ Анимация перехода
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = tabBarController
        
        print("[AuthViewController, switchToTabBarController]: успешно переключились на TabBarController")
    }
    
    private func showErrorAlert(error: Error) {
        print("[AuthViewController, showErrorAlert]: показываем alert с ошибкой")
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("[AuthViewController, webViewViewControllerDidCancel]: пользователь отменил авторизацию")
        goBackToSplash()
    }
    private func goBackToSplash() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("[AuthViewController, goBackToSplash]: ошибка - не удалось найти window")
            return
        }
        
        let splashViewController = SplashViewController()
        
        // Анимация перехода слева
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = splashViewController
        
        print("[AuthViewController, goBackToSplash]: успешно вернулись к SplashViewController")
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
