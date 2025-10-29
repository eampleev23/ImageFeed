//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 27.10.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
}

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
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[dataTask]: urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[dataTask]: urlSessionError - неизвестная ошибка сессии, URL: \(request.url?.absoluteString ?? "unknown")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        // Создает декодер
        let decoder = JSONDecoder()
        
        // Создает запрос уже через кастомный метод data
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? "Нечитаемые данные"
                    print("[objectTask]: decodingError - \(error.localizedDescription), Данные: \(dataString)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[objectTask]: networkError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
