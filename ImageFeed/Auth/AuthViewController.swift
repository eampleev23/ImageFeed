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
        static let segueIDFromStoryBoard: String = "ShowWebView"
    }
    
    private let oauthToService = OAuth2Service.shared
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AuthConstants.segueIDFromStoryBoard {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                fatalError("Failed to prepare for \(AuthConstants.segueIDFromStoryBoard)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupView(){
        
        view.backgroundColor = YPColors.black
        view.addSubview(logoImageView)
        view.addSubview(loginUIButton)
    }
    
    @objc
    private func didTapLoginBtn(){
        performSegue(withIdentifier: AuthConstants.segueIDFromStoryBoard, sender: self)
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
        
        print("Authorization code received: \(code)")
        oauthToService.fetchOAuthToken(code: code) { [weak self] result in
            
            switch result {
            case .success(let token):
                print("Successfully received token: \(token)")
                // Токен получен и сохранен, можно переходить к следующему экрану
                self?.delegate?.didAuthenticate(self ?? AuthViewController())
                
            case .failure(let error):
                print("Failed to get token: \(error.localizedDescription)")
                // Показываем alert с ошибкой
                self?.showErrorAlert(error: error)
            }
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
