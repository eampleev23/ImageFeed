//
//  ImageList.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 29.10.2025.
//

import Foundation

final class ImageListService {
    
    // Массив для хранения загруженных фотографий
    private(set) var photos: [Photo] = []
    
    // Оповещение об изменении данных
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    // Текущая задача загрузки
    private var fetchTask: URLSessionTask?
    
    // Номер следующей страницы для загрузки
    private var nextPage = 1
    
    // Флаг, указывающий, загружены ли все страницы
    private var isFetching = false
    
    //MARK: - Network methods
    
    func fetchPhotosNextPage(){
        
        // Если уже идет загрузка прерываем выполнение
        guard !isFetching else {return}
        
        isFetching = true
        
        // Создаем URL и запрос
        guard let url = AppConstants.getPhotosURL(page: nextPage, perPage: 10) else {
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
                        name: ImageListService.didChangeNotification,
                        object: self
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
    
    private func convertToPhoto(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        
        _ = ISO8601DateFormatter()
        let createdAt = Date()
        
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
