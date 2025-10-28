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
        
        view.backgroundColor = .ypBlack
        
        tabBar.barTintColor = .ypBlack
        tabBar.backgroundColor = .ypBlack
        tabBar.tintColor = .ypWhite
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .ypBlack
            
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            
            appearance.stackedLayoutAppearance.normal.iconColor = .ypGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.ypGray
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = .ypWhite
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.ypWhite
            ]
            
            tabBar.standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
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
