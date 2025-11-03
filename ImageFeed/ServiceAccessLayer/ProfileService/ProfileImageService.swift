//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 24.10.2025.
//

import Foundation

final class ProfileImageService {
    
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
                completion(.failure(AppError.unauthorized))
                return
            }
            
            guard let request = makeProfileRequest(token: token, username: username) else {
                print("[ProfileImageService]: invalidRequest - не удалось создать URL запроса для пользователя: \(username)")
                DispatchQueue.main.async {
                    completion(.failure(AppError.invalidRequest))
                }
                return
            }
            
            task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
                switch result {
                case .success(let userResult):
                    let avatarURLString = userResult.profileImage.large
                    
                    guard !avatarURLString.isEmpty,
                          URL(string: avatarURLString) != nil else {
                        print("[ProfileImageService]: invalidAvatarURL - получен некорректный URL аватара: \(avatarURLString)")
                        DispatchQueue.main.async {
                            completion(.failure(AppError.invalidAvatarURL))
                        }
                        return
                    }
                    self?.avatarURL = userResult.profileImage.large
                    
                    DispatchQueue.main.async {
                        completion(.success(userResult.profileImage.large))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": userResult.profileImage.large])
                    }
                    
                case .failure(let error):
                    print("[ProfileImageService]: imageRequestError - \(error.localizedDescription), пользователь: \(username)")
                    let finalError: Error
                    if let appError = error as? AppError {
                        switch appError {
                        case .serverError(let statusCode) where statusCode == 404:
                            finalError = AppError.avatarNotFound
                        default:
                            finalError = error
                        }
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
    
    private func makeProfileRequest(token: String, username: String) -> URLRequest? {
        
        let sanitizedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? username
        let url = AppConstants.getUserURL.appendingPathComponent(sanitizedUsername)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ProfileImageService {
    func cleanAvatarURL() {
        avatarURL = nil
    }
}
