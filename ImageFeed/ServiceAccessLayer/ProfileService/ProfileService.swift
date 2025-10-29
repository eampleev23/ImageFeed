//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 23.10.2025.
//

import Foundation

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
                completion(.failure(AppError.invalidRequest))
            }
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                
                let profile = Profile(
                    userName: profileResult.username,
                    name: self?.formatName(firstName: profileResult.firstName, lastName: profileResult.lastName) ?? "",
                    loginName: self?.formatLoginName(username: profileResult.username) ?? "",
                    bio: profileResult.bio
                )
                self?.profile = profile
                
                
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
                
            case .failure(let error):
                print("[ProfileService]: profileRequestError - \(error.localizedDescription)")
                
                let finalError: Error
                if let appError = error as? AppError, appError.statusCode == 404 {
                    finalError = AppError.profileNotFound
                } else {
                    finalError = error
                }
                DispatchQueue.main.async {
                    completion(.failure(finalError))
                }
            }
            self?.task = nil
        }
        
        task?.resume()
    }
    
    private func formatName(firstName: String?, lastName: String?) -> String {
        
        switch (firstName, lastName) {
        case (let first?, let last?):
            return "\(first) \(last)"
        case (let first?, nil):
            return first
        case (nil, let last?):
            return last
        case (nil, nil):
            return ""
        }
    }
    
    private func formatLoginName(username: String?) -> String {
        
        guard let username = username, !username.isEmpty else { return "" }
        return "@\(username)"
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
