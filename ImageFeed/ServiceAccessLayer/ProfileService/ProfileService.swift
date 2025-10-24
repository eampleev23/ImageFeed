//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 23.10.2025.
//

import Foundation

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String
}

// Сюда парсится ответ на запрос информации о профиле (соответствует по структуре ответу от апи)
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init(){}
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // Если уже запущен запрос, то отменяем
        task?.cancel()
        
        // Создаем урл для запроса
        guard let requestURL = makeProfileRequest(token: token) else {
            DispatchQueue.main.async{
                completion(.failure(URLError(.badURL)))}
            return
        }
        
        // Создаем запрос
        let task = urlSession.dataTask(with: requestURL) { [weak self] data, response, error in
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
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                
                let profile = Profile(
                    userName: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? ""
                )
                self?.profile = profile
                print("completion(.success(profile))")
                DispatchQueue.main.async{
                    completion(.success(profile))}
            } catch {
                print("completion(.failure(error))")
                DispatchQueue.main.async{
                    completion(.failure(error))}
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
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
