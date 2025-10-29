//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 27.10.2025.
//

import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[dataTask]: NetworkError - код ошибки \(statusCode), URL: \(request.url?.absoluteString ?? "unknown")")
                    
                    // Преобразование HTTP кодов в AppError
                    let appError: AppError
                    switch statusCode {
                    case 400:
                        appError = .invalidRequest
                    case 401:
                        appError = .unauthorized
                    case 403:
                        appError = .serverError(statusCode: statusCode)
                    case 404:
                        appError = .serverError(statusCode: statusCode)
                    case 429:
                        appError = .networkError(description: "Слишком много запросов")
                    case 500...599:
                        appError = .serverError(statusCode: statusCode)
                    default:
                        appError = .serverError(statusCode: statusCode)
                    }
                    fulfillCompletionOnTheMainThread(.failure(appError))
                }
            } else if let error = error {
                print("[dataTask]: urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown")")
                
                let appError = AppError.networkError(description: error.localizedDescription)
                fulfillCompletionOnTheMainThread(.failure(appError))
            } else {
                print("[dataTask]: urlSessionError - неизвестная ошибка сессии, URL: \(request.url?.absoluteString ?? "unknown")")
                
                fulfillCompletionOnTheMainThread(.failure(AppError.networkError(description: "Неизвестная ошибка сессии")))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? "Нечитаемые данные"
                    print("[objectTask]: decodingError - \(error.localizedDescription), Данные: \(dataString)")
                    
                    // ЗАМЕНА NetworkError на AppError
                    completion(.failure(AppError.parsingError))
                }
            case .failure(let error):
                print("[objectTask]: networkError - \(error.localizedDescription)")
                // error уже будет AppError, так как data(for:) теперь возвращает AppError
                completion(.failure(error))
            }
        }
        return task
    }
}
