//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 19.10.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard var uRLComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        uRLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AppConstants.accessKey),
            URLQueryItem(name: "client_secret", value: AppConstants.secretKey),
            URLQueryItem(name: "redirect_uri", value: AppConstants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenURL = uRLComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        return request
    }
    
    private func fetchOAuthToken(code: String) {
        guard let uRLRequest = makeOAuthTokenRequest(code: code) else { return }
        URLSession.shared.dataTask(with: uRLRequest)
    }
}
