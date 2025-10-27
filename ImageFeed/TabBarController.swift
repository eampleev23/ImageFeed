//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 27.10.2025.
//

import UIKit
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "profile_no_active"),
            selectedImage: UIImage(named: "profile_active")
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
