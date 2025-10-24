//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get { return UserDefaults.standard.string(forKey: AppConstants.barerTokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConstants.barerTokenKey)
        }
    }
}
