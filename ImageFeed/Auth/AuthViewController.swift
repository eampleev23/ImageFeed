//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//

import UIKit

enum AuthControllerConstants {
    static let logoImageViewImageName: String = "logo_of_unsplash"
    
}

final class AuthViewController: UIViewController {
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: AuthControllerConstants.logoImageViewImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.tintColor = YPColors.white
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        
        uiButton.setTitle("Войти", for: .normal)
        uiButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        uiButton.setTitleColor(YPColors.black, for: .normal)
        
        uiButton.backgroundColor = YPColors.white
        uiButton.layer.cornerRadius = 16
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
        print("login_btn tapped")
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
                constant: 16
            ),
            loginUIButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            loginUIButton.heightAnchor.constraint(
                equalToConstant: 48
            ),
            loginUIButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -106
            ),
        ])
    }
    
    private func setupButtonTarget() {
        loginUIButton.addTarget(self, action: #selector(didTapLoginBtn), for: .touchUpInside)
    }
    
}
