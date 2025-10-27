//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            guard let token: String = KeychainWrapper.standard.string(forKey: "Auth token") else {
                print("[OAuth2TokenStorage]: get value error")
                return nil
            }
            return token
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: "Auth token")
                guard isSuccess else {
                    print("[OAuth2TokenStorage]: set value error, newValue: \(newValue)")
                    return
                }
            } else {
                removeToken()
            }
        }
    }
    
    func removeToken() {
        let isSuccess = KeychainWrapper.standard.removeObject(forKey: "Auth token")
        if !isSuccess {
            print("[OAuth2TokenStorage]: remove token error")
        }
    }
}
