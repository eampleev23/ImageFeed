//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 19.10.2025.
//

import Foundation

final class OAuth2Service {
    
    private enum NetworkError: Error {
        case codeError
        case invalidRequest
        case parsingError
    }
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let uRLRequest = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: uRLRequest) { data, response, error in
            if let error {
                print("[OAuth2Service] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Проверяем HTTP статус-код
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[OAuth2Service] Invalid response type")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[OAuth2Service] Server returned error status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.codeError))
                }
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                print("[OAuth2Service] No data received")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.parsingError))
                }
                return
            }
            
            // Декодируем JSON и извлекаем токен
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let token = tokenResponse.access_token
                
                // Сохраняем токен
                OAuth2TokenStorage.shared.token = token
                
                DispatchQueue.main.async {
                    completion(.success(token))
                }
                
            } catch {
                print("[OAuth2Service] JSON parsing error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
}
