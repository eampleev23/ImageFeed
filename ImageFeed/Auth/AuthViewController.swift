//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private enum Constants {
        static let logoImageViewImageResourse: ImageResource = .logoOfUnsplash
        static let loginUIButtonText: String = "Войти"
        static let loginUIButtonFontSize: CGFloat = 17
        static let loginUIButtonCornerRadius: CGFloat = 16
        static let loginUIButtonLeadingAnchor: CGFloat = 16
        static let loginUIButtonTrailingAnchor: CGFloat = -16
        static let loginUIButtonHeightAnchor: CGFloat = 48
        static let loginUIButtonBottomAnchor: CGFloat = -106
    }
    
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var logoImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(resource: Constants.logoImageViewImageResourse))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loginUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.tintColor = YPColors.white
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        
        uiButton.setTitle(Constants.loginUIButtonText, for: .normal)
        uiButton.titleLabel?.font = UIFont.systemFont(ofSize: Constants.loginUIButtonFontSize, weight: .bold)
        uiButton.setTitleColor(YPColors.black, for: .normal)
        
        uiButton.backgroundColor = YPColors.white
        uiButton.layer.cornerRadius = Constants.loginUIButtonCornerRadius
        uiButton.layer.masksToBounds = true
        
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
        showWebViewViewController()
    }
    
    private func showWebViewViewController() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
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
                constant: Constants.loginUIButtonLeadingAnchor
            ),
            loginUIButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constants.loginUIButtonTrailingAnchor
            ),
            loginUIButton.heightAnchor.constraint(
                equalToConstant: Constants.loginUIButtonHeightAnchor
            ),
            loginUIButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Constants.loginUIButtonBottomAnchor
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
        
        print("[AuthViewController, webViewViewController(didAuthenticateWithCode)]: получен код авторизации: \(code.prefix(5))..")
        
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let token):
                print("[AuthViewController, webViewViewController(didAuthenticateWithCode)]: успешно получен токен: \(token.prefix(10))...")
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        
        let splashViewController = SplashViewController()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = splashViewController
            }, completion: { success in
                if success {
                    print("[AuthViewController, switchToTabBarController]: успешно переключились на SplashViewController для загрузки профиля")
                }
            })
        }
    }
    
    private func showErrorAlert(error: Error) {
        
        let title: String
        let message: String
        let recoveryMessage: String?
        
        if let appError = error as? AppError {
            title = "Ошибка авторизации"
            message = appError.errorDescription ?? "Не удалось войти в систему"
            recoveryMessage = appError.recoverySuggestion
        } else {
            title = "Что-то пошло не так"
            message = "Не удалось войти в систему"
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
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
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
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
