//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 27.10.2025.
//

import UIKit
final class TabBarController: UITabBarController {
    
    private enum TabBarConstants {
        static let tabBarItemImageFeedNoActive = "feed_no_active"
        static let tabBarItemImageFeedActive = "feed_active"
        static let tabBarItemImageProfileActive = "profile_active"
        static let tabBarItemImageProfileNoActive = "profile_no_active"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupViewControllers()
    }
    
    private func setupTabBarAppearance() {
        print("[TabBarController, setupTabBarAppearance]: настраиваем внешний вид TabBar")
        
        view.backgroundColor = .ypBlack
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypGray
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = .ypGray
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypWhite
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = .ypWhite
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.barTintColor = .ypBlack
        tabBar.backgroundColor = .ypBlack
        tabBar.tintColor = .ypWhite
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.isTranslucent = false
        
    }
    
    private func setupViewControllers(){
        
        let imageListViewController = ImageListViewController()
        let profileViewController = ProfileViewController()
        
        imageListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: TabBarConstants.tabBarItemImageFeedNoActive),
            selectedImage: UIImage(named: TabBarConstants.tabBarItemImageFeedActive)
        )
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: TabBarConstants.tabBarItemImageProfileNoActive),
            selectedImage: UIImage(named: TabBarConstants.tabBarItemImageProfileActive)
        )
        
        self.viewControllers = [imageListViewController, profileViewController]
        
    }
}
