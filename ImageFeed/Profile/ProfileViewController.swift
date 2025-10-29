//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 12.10.2025.
//

import Kingfisher
import UIKit

private enum ProfileLayotConstants {
    
    static let globalLeadingAndRightAnchor: CGFloat = 16
    static let globalTopAnchor: CGFloat = 8
    static let globalOneLineUILabelNumberOfLines: Int = 1
    static let globalFontSizeUILabelStandart: CGFloat = 13
    
    static let profileImageViewTopAnchor: CGFloat = 32
    static let profileImageViewHeightAndWidth: CGFloat = 70
    static let profileImageViewCornerRadius: CGFloat = 35
    
    static let fullNameUILabelFontSize: CGFloat = 23
    
    static let logoutUIButtonRightAnchor: CGFloat = -16
    static let logoutUIButtonTopAnchor: CGFloat = 45
}

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .avatarPlaceholder))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var fullNameUILabelView: UILabel = {
        
        let labelView = UILabel()
        labelView.text = ""
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.fullNameUILabelFontSize, weight: .bold)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private lazy var nicknameUILabelView: UILabel = {
        let labelView = UILabel()
        labelView.text = ""
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.gray
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private lazy var bioUILabelView: UILabel = {
        let labelView = UILabel()
        labelView.text = ""
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = UIFont.systemFont(ofSize: ProfileLayotConstants.globalFontSizeUILabelStandart, weight: .regular)
        labelView.textColor = YPColors.white
        labelView.numberOfLines = ProfileLayotConstants.globalOneLineUILabelNumberOfLines
        return labelView
    }()
    
    private lazy var logoutUIButton: UIButton = {
        let uiButton = UIButton()
        uiButton.setImage(UIImage(resource: .logoutBtn), for: .normal)
        uiButton.tintColor = YPColors.red
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        return uiButton
    }()
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ){[weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        if let profile = profileService.profile {
            updateProfileDetails(with: profile)
        }
        setupView()
        setupConstraints()
        setupButtonTarget()
    }
    private func updateAvatar(){
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileImageView.kf.setImage(with: url)
    }
    
    private func updateProfileDetails(with profile: Profile) {
        
        fullNameUILabelView.text = profile.name.isEmpty
        ? ""
        : profile.name
        
        nicknameUILabelView.text = profile.loginName.isEmpty
        ? ""
        : profile.loginName
        
        bioUILabelView.text = profile.bio.isEmpty
        ? ""
        : profile.bio
        
    }
    
    private func setupView(){
        view.backgroundColor = YPColors.black
        profileImageView.layer.cornerRadius = ProfileLayotConstants.profileImageViewCornerRadius
        profileImageView.clipsToBounds = true
        view.addSubview(profileImageView)
        view.addSubview(fullNameUILabelView)
        view.addSubview(nicknameUILabelView)
        view.addSubview(bioUILabelView)
        view.addSubview(logoutUIButton)
    }
    
    @objc
    private func didTapLogoutBtn(){
        showLogoutConfirmationAlert()
    }
    
    private func showLogoutConfirmationAlert() {
        let alert = UIAlertController(
            title: "Подтверждение выхода",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        OAuth2TokenStorage.shared.removeToken()
        
        // 2. Очищаем данные профиля
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatarURL()
        
        // 3. Очищаем кеш изображений Kingfisher
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        
        // 4. Переключаемся на SplashViewController
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
        let splashViewController = SplashViewController()
        
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
