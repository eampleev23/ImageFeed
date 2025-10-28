//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 24.10.2025.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let small: String
}

final class ProfileImageService {
    
    private enum NetworkError: Error {
        case invalidURL
    }
    
    private var task: URLSessionTask?
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private init(){}
    
    private let session = URLSession.shared
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            
            task?.cancel()
            
            guard let token = OAuth2TokenStorage.shared.token else {
                let error = NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])
                print("[ProfileImageService]: authError - отсутствует токен авторизации: \(error)")
                completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
                return
            }
            
            guard let request = makeProfileRequest(token: token, username: username) else {
                print("[ProfileImageService]: invalidRequest - не удалось создать URL запроса для пользователя: \(username)")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badURL)))
                }
                return
            }
            
            task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
                switch result {
                case .success(let userResult):
                    self?.avatarURL = userResult.profileImage.small
                    
                    DispatchQueue.main.async {
                        completion(.success(userResult.profileImage.small))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": userResult.profileImage.small])
                    }
                    
                case .failure(let error):
                    print("[ProfileImageService]: imageRequestError - \(error.localizedDescription), пользователь: \(username)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                self?.task = nil
            }
            
            task?.resume()
        }
    
    private func makeProfileRequest(token: String, username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // Функция для вывода сырого JSON
    private func printRawJSON(data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== RAW JSON RESPONSE ===")
            print(jsonString)
            print("=== END OF JSON ===")
        } else {
            print("Не удалось преобразовать данные в строку")
        }
        
        // Альтернативный вариант: красивый вывод с форматированием
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                print("=== PRETTY JSON ===")
                print(prettyString)
                print("=== END OF PRETTY JSON ===")
            }
        } catch {
            print("Не удалось отформатировать JSON: \(error)")
        }
    }
    
}

extension ProfileImageService {
    func cleanAvatarURL() {
        avatarURL = nil
    }
}
