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
    private(set) var avtarURL: String?
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            task?.cancel()
            
            guard let token = OAuth2TokenStorage.shared.token else {
                completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
                return
            }
            
            // Создаем урл для запроса
            guard let requestURL = makeProfileRequest(
                token: token,
                username: username
            ) else {
                DispatchQueue.main.async{
                    completion(.failure(URLError(.badURL)))}
                return
            }
            let task = session.dataTask(with: requestURL) { [weak self] data, response, error in
                // Проверяем, есть ли ошибка
                if let error = error {
                    DispatchQueue.main.async{
                        completion(.failure(error))}
                    self?.task = nil
                    return
                }
                
                // Проверяем, что данные получены
                guard let data = data else {
                    DispatchQueue.main.async{
                        completion(.failure(URLError(.badServerResponse)))}
                    self?.task = nil
                    return
                }
                
                self?.printRawJSON(data: data)
                
                do {
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    
                    self?.avtarURL = userResult.profileImage.small
                    print("completion(.success(userResult))")
                    DispatchQueue.main.async{
                        completion(.success(userResult.profileImage.small))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": userResult.profileImage.small])
                    }
                } catch {
                    print("completion(.failure(error))")
                    DispatchQueue.main.async{
                        completion(.failure(error))}
                }
                self?.task = nil
            }
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
