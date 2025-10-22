//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation

enum NetworkError {
    case httpStatusCode(Int)
    case uRLRequestError(Error)
    case uRLSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        complation: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                complation(result)
            }
        }
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode) as! Error)) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.uRLRequestError(error) as! Error)) // 5
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.uRLSessionError as! Error)) // 6
            }
        })
        
        return task
    }
}
