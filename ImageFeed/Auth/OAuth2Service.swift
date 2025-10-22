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
        
        if activeTokenRequestIfIs != nil {
            
            if activeAuthCodeIfIs != code {
                activeTokenRequestIfIs?.cancel()
            } else {
                completion(.failure(AuthServiceErrors.invalidRequest))
                return
            }
        } else {
            if activeAuthCodeIfIs == code {
                completion(.failure(AuthServiceErrors.invalidRequest))
                return
            }
        }
        activeAuthCodeIfIs = code
        guard let newTokenRequest = makeOAuthTokenRequestURL(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(AuthServiceErrors.invalidRequest))
            }
            return
        }
        
        let tokenRequestToDo = URLSession.shared.dataTask(with: newTokenRequest) { data, response, error in
            
            if let error {
                print("[OAuth2Service] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[OAuth2Service] Invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(AuthServiceErrors.codeError))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[OAuth2Service] Server returned error status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(AuthServiceErrors.codeError))
                }
                return
            }
            
            guard let data = data else {
                print("[OAuth2Service] No data received")
                DispatchQueue.main.async {
                    completion(.failure(AuthServiceErrors.parsingError))
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let token = tokenResponse.access_token
                
                OAuth2TokenStorage.shared.token = token
                
                DispatchQueue.main.async {
                    completion(.success(token))
                    self.activeTokenRequestIfIs = nil
                    self.activeAuthCodeIfIs = nil
                }
                
            } catch {
                print("[OAuth2Service] JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        self.activeTokenRequestIfIs = tokenRequestToDo
        tokenRequestToDo.resume()
    }
}
