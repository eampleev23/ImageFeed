//
//  ImageList.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 29.10.2025.
//

import Foundation

final class ImagesListService {
    
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    private var fetchTask: URLSessionTask?
    
    private var nextPage = 1
    
    private var isFetching = false
    private var isLiking = false
    
    //MARK: - Network methods
    
    func fetchPhotosNextPage(){
        
        guard !isFetching else {return}
        
        isFetching = true
        
        guard let url = AppConstants.getPhotosURL(page: nextPage, perPage: 20) else {
            isFetching = false
            return
        }
        
        var request = URLRequest(url:url)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])
            print("[ImageListService, fetchPhotosNextPage]: authError - отсутствует токен авторизации: \(error)")
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        fetchTask = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result <[PhotoResult], Error>) in
            
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map{self.convertToPhoto(from: $0)}
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.nextPage += 1
                    self.isFetching = false
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["type" : "photosLoaded"]
                    )
                }
                
            case .failure( let error):
                print("Error fetching photos: \(error)")
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
        }
        
        fetchTask?.resume()
    }
    
    func changeLike(photoID: String, isLikeToSet: Bool, _ completion: @escaping (Result <Void, Error>) -> Void) {
        
        guard !isLiking else {return}
        isLiking = true
        
        guard let url = AppConstants.setLikeURL(photoID: photoID) else {
            isLiking = false
            return
        }
        
        var request: URLRequest = URLRequest(url:url)
        
        if isLikeToSet == true {
            request.httpMethod = "POST"
        } else {
            request.httpMethod = "DELETE"
        }
        
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])
            print("[ImageListService, fetchPhotosNextPage]: authError - отсутствует токен авторизации: \(error)")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        fetchTask = URLSession.shared.objectTask(for: request) {
            
            [weak self] (result: Result <EmptyResponse, Error>) in
            
            guard let self else {return}
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isLiking = false
                    completion( .success( () ) )
                }
            case .failure(let error):
                print("Error change like photo: \(error)")
                DispatchQueue.main.async {
                    self.isLiking = false
                    completion(.failure(error))
                }
            }
        }
        fetchTask?.resume()
    }
    
    private func convertToPhoto(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = result.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.regular,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
