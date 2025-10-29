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
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService]: invalidRequest - не удалось создать URL запроса")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        
        // Используем новый универсальный метод
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    userName: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? ""
                )
                self?.profile = profile
                
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
                
            case .failure(let error):
                print("[ProfileService]: profileRequestError - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            self?.task = nil
        }
        
        task?.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        
        let url = AppConstants.getUserAvatarURL
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}

extension ProfileService {
    func cleanProfile() {
        profile = nil
    }
}
