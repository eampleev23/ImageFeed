//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 19.10.2025.
//

import Foundation

final class OAuth2Service {
    
    private enum AuthServiceErrors: Error {
        case codeError
        case invalidRequest
        case parsingError
        case duplicateRequest
    }
    
    static let shared = OAuth2Service()
    
    private var activeTokenRequestIfIs: URLSessionTask?
    private var activeAuthCodeIfIs: String?
    
    private init() {}
    
    private func makeOAuthTokenRequestURL(code: String) -> URLRequest? {
        
        guard var uRLComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard activeAuthCodeIfIs != code else {
            completion(.failure(AuthServiceErrors.duplicateRequest))
            return
        }
        activeTokenRequestIfIs?.cancel()
        activeAuthCodeIfIs = code
        
        guard let newTokenRequestURL = makeOAuthTokenRequestURL(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(AuthServiceErrors.invalidRequest))
            }
            return
        }
        
        // Используем новый универсальный метод
        let tokenRequestToDo = URLSession.shared.objectTask(for: newTokenRequestURL) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                let token = tokenResponse.access_token
                OAuth2TokenStorage.shared.token = token
                
                DispatchQueue.main.async {
                    completion(.success(token))
                    self?.activeTokenRequestIfIs = nil
                    self?.activeAuthCodeIfIs = nil
                }
                
            case .failure(let error):
                print("[OAuth2Service] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self?.activeTokenRequestIfIs = nil
                    self?.activeAuthCodeIfIs = nil
                }
            }
        }
        
        self.activeTokenRequestIfIs = tokenRequestToDo
        tokenRequestToDo.resume()
    }
}
