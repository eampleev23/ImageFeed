//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 12.10.2025.
//

import UIKit

enum Constants{
    
    static let globalLeadingAndRightAnchor: CGFloat = 16
    static let globalTopAnchor: CGFloat = 8
    static let globalOneLineUILabelNumberOfLines: Int = 1
    static let globalFontSizeUILabelStandart: CGFloat = 13
    
    static let profileImageViewImageName: String = "avatar"
    static let profileImageViewTopAnchor: CGFloat = 32
    static let profileImageViewHeightAndWidth: CGFloat = 70
    
    static let fullNameUILabelText: String = "Екатерина Новикова"
    static let fullNameUILabelFontSize: CGFloat = 23
    
    static let nicknameUILabelText: String = "@ekaterina_nov"
    
    static let greetingsUILabelText: String = "Hello, world!"
    
    static let logoutUIButtonImageName: String = "logout_btn"
    static let logoutUIButtonRightAnchor: CGFloat = -16
    static let logoutUIButtonTopAnchor: CGFloat = 45
}

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let profileImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: Constants.profileImageViewImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let fullNameUILabelView: UILabel = {
        
        let labelView = UILabel()
        labelView.text = Constants.fullNameUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: Constants.fullNameUILabelFontSize, weight: .bold)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = Constants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let nicknameUILabel: UILabel = {
        let labelView = UILabel()
        labelView.text = Constants.nicknameUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: Constants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.gray
        labelView.numberOfLines = Constants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let greetingsUILabel: UILabel = {
        let labelView = UILabel()
        labelView.text = Constants.nicknameUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: Constants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = Constants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let logoutUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.setImage(UIImage(named: Constants.logoutUIButtonImageName), for: .normal)
        uiButton.tintColor = YPColors.red
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        return uiButton
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupButtonTarget()
    }
    
    @objc
    private func didTapLogoutBtn(){
        print("logout_btn tapped")
    }
    
    private func setupView(){
        
        view.backgroundColor = YPColors.black
        view.addSubview(profileImageView)
        view.addSubview(fullNameUILabelView)
        view.addSubview(nicknameUILabel)
        view.addSubview(greetingsUILabel)
        view.addSubview(logoutUIButton)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.globalLeadingAndRightAnchor
            ),
            profileImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.profileImageViewTopAnchor
            ),
            profileImageView.widthAnchor.constraint(
                equalToConstant: Constants.profileImageViewHeightAndWidth
            ),
            profileImageView.heightAnchor.constraint(
                equalToConstant: Constants.profileImageViewHeightAndWidth
            ),
            fullNameUILabelView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.globalLeadingAndRightAnchor
            ),
            fullNameUILabelView.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: Constants.globalTopAnchor
            ),
            nicknameUILabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.globalLeadingAndRightAnchor
            ),
            nicknameUILabel.topAnchor.constraint(
                equalTo: fullNameUILabelView.bottomAnchor,
                constant: Constants.globalTopAnchor
            ),
            logoutUIButton.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: Constants.logoutUIButtonRightAnchor
            ),
            logoutUIButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.logoutUIButtonTopAnchor
            )
        ])
    }
    
    private func setupButtonTarget() {
        logoutUIButton.addTarget(self, action: #selector(didTapLogoutBtn), for: .touchUpInside)
    }
}
