//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 12.10.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let globalLeadingAndRightAnchor: CGFloat = 16
    private let globalTopAnchor: CGFloat = 8
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = YPColors.black
        
        let profileImage = UIImage(named: "avatar")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: globalLeadingAndRightAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        let fullName = UILabel()
        fullName.text = "Екатерина Новикова"
        fullName.translatesAutoresizingMaskIntoConstraints = false
        
        fullName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        fullName.textColor = YPColors.white
        fullName.numberOfLines = 1
        
        view.addSubview(fullName)
        
        fullName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: globalLeadingAndRightAnchor).isActive = true
        fullName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: globalTopAnchor).isActive = true
        
        let nikname = UILabel()
        nikname.text = "@ekaterina_nov"
        nikname.translatesAutoresizingMaskIntoConstraints = false
        nikname.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        nikname.textColor = YPColors.gray
        nikname.numberOfLines = 1
        
        view.addSubview(nikname)
        
        nikname.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: globalLeadingAndRightAnchor).isActive = true
        nikname.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: globalTopAnchor).isActive = true
        
        let greetings = UILabel()
        greetings.text = "Hello, world!"
        greetings.translatesAutoresizingMaskIntoConstraints = false
        greetings.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        greetings.textColor = YPColors.white
        greetings.numberOfLines = 1
        
        view.addSubview(greetings)
        
        greetings.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: globalLeadingAndRightAnchor).isActive = true
        greetings.topAnchor.constraint(equalTo: nikname.bottomAnchor, constant: globalTopAnchor).isActive = true
        
        let logoutBtn = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage(),
            target: self,
            action: #selector(Self.didTapLogoutBtn))
        
        logoutBtn.tintColor = YPColors.red
        
        logoutBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoutBtn)
        
        logoutBtn.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        logoutBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        
    }
    
    @objc
    private func didTapLogoutBtn(){
        print("logout_btn tapped")
    }
    
}
