//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 12.10.2025.
//

import UIKit

enum ProfileLayotConstants {
    
    static let globalLeadingAndRightAnchor: CGFloat = 16
    static let globalTopAnchor: CGFloat = 8
    static let globalOneLineUILabelNumberOfLines: Int = 1
    static let globalFontSizeUILabelStandart: CGFloat = 13
    
    static let profileImageViewImageName: String = "avatar"
    static let profileImageViewTopAnchor: CGFloat = 0
    static let profileImageViewHeightAndWidth: CGFloat = 70
    
    static let fullNameUILabelText: String = "Екатерина Новикова"
    static let fullNameUILabelFontSize: CGFloat = 23
    
    static let nicknameUILabelText: String = "@ekaterina_nov"
    
    static let bioUILabelText: String = "Hello, world!"
    
    static let logoutUIButtonImageName: String = "logout_btn"
    static let logoutUIButtonRightAnchor: CGFloat = -16
    static let logoutUIButtonTopAnchor: CGFloat = 13
}

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let profileImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: ProfileLayotConstants.profileImageViewImageName))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let fullNameUILabelView: UILabel = {
        
        let labelView = UILabel()
        labelView.text = ProfileLayotConstants.fullNameUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.fullNameUILabelFontSize, weight: .bold)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let nicknameUILabelView: UILabel = {
        let labelView = UILabel()
        labelView.text = ProfileLayotConstants.nicknameUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.gray
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let bioUILabelView: UILabel = {
        let labelView = UILabel()
        labelView.text = ProfileLayotConstants.bioUILabelText
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private let logoutUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.setImage(UIImage(named: ProfileLayotConstants.logoutUIButtonImageName), for: .normal)
        uiButton.tintColor = YPColors.red
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        return uiButton
    }()
    
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let profile = profileService.profile {
            updateProfileDetails(with: profile)
        }
        //        profileService.fetchProfile(
        //            OAuth2TokenStorage.shared.token ?? "") { result in
        //                switch result {
        //                case .success(let profile):
        //                    self.updateProfileDetails(with: profile)
        //                case .failure(let error):
        //                    print("\(error)")
        //                }
        //            }
        
        setupView()
        setupConstraints()
        setupButtonTarget()
    }
    
    private func updateProfileDetails(with profile: Profile) {
        
        fullNameUILabelView.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        
        nicknameUILabelView.text = profile.loginName.isEmpty
        ? "Nickname не указан"
        : profile.loginName
        
        bioUILabelView.text = profile.bio.isEmpty
        ? "Биография не заполнена"
        : profile.bio
        
    }
    
    private func setupView(){
        view.backgroundColor = YPColors.black
        view.addSubview(profileImageView)
        view.addSubview(fullNameUILabelView)
        view.addSubview(nicknameUILabelView)
        view.addSubview(bioUILabelView)
        view.addSubview(logoutUIButton)
    }
    
    @objc
    private func didTapLogoutBtn(){
        print("didTapLogoutBtn")
        UserDefaults.standard.removeObject(forKey: AppConstants.barerTokenKey)
        switchToSplashViewController()
    }
    
    private func switchToSplashViewController(){
        
        // Получаем активную window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаем экземпляр нужного контроллера из Storyboard
        let splashViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "SplashViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = splashViewController
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ProfileLayotConstants.globalLeadingAndRightAnchor
            ),
            profileImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ProfileLayotConstants.profileImageViewTopAnchor
            ),
            profileImageView.widthAnchor.constraint(
                equalToConstant: ProfileLayotConstants.profileImageViewHeightAndWidth
            ),
            profileImageView.heightAnchor.constraint(
                equalToConstant: ProfileLayotConstants.profileImageViewHeightAndWidth
            ),
            fullNameUILabelView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ProfileLayotConstants.globalLeadingAndRightAnchor
            ),
            fullNameUILabelView.topAnchor.constraint(
                equalTo: profileImageView.bottomAnchor,
                constant: ProfileLayotConstants.globalTopAnchor
            ),
            nicknameUILabelView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ProfileLayotConstants.globalLeadingAndRightAnchor
            ),
            nicknameUILabelView.topAnchor.constraint(
                equalTo: fullNameUILabelView.bottomAnchor,
                constant: ProfileLayotConstants.globalTopAnchor
            ),
            bioUILabelView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: ProfileLayotConstants.globalLeadingAndRightAnchor
            ),
            bioUILabelView.topAnchor.constraint(
                equalTo: nicknameUILabelView.bottomAnchor,
                constant: ProfileLayotConstants.globalTopAnchor
            ),
            logoutUIButton.rightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.rightAnchor,
                constant: ProfileLayotConstants.logoutUIButtonRightAnchor
            ),
            logoutUIButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: ProfileLayotConstants.logoutUIButtonTopAnchor
            )
        ])
    }
    
    private func setupButtonTarget() {
        logoutUIButton.addTarget(self, action: #selector(didTapLogoutBtn), for: .touchUpInside)
    }
}
