//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init(){}
    
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get { return UserDefaults.standard.string(forKey: tokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
