//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 19.10.2025.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init(){}
    
    // MARK: - Получение OAuth токена
    func fetchOAuthToken(code: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let oauthResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(oauthResponse.accessToken))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(
            string: "https://unsplash.com/oauth/token"
        ) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AppConstants.accessKey),
            URLQueryItem(name: "client_secret", value: AppConstants.secretKey),
            URLQueryItem(name: "redirect_uri", value: AppConstants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenURL = urlComponents.url else { return nil }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        return request
    }
}

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case noData
    case decodingError
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
