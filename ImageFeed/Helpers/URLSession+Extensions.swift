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
    
    // Существующий метод для работы с Data. Получает объект типа URLRequest и замыкание, которое будет вызвано после выполнения тела метода. Замыкание будет получать стандартное перечисление swift - Result с объектом Data в .success
    // и с объектом Error в .failure. Сам метод будет возвращать URLSessionTask (по сути запрос вместе с инструкциями по обработке любого возможного результата)
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        // Для лаконичности заводим fulfillCompletionOnTheMainThread, чтобы вызывать его с разными параметрами на главном потоке в зависимости от результата запроса
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        // Заводим тот самый URLSessionTask, который должен вернуть описываемый нами метод data, используя функцию dataTask, которая получает на вход request:URLRequest, переданный в качестве входного параметра метода data и completionHandler, который в зависимости от результата запроса будет вызывать fulfillCompletionOnTheMainThread с разными параметрами .success или .failure
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        // Возвращаем подготовленный запрос task: URLSessionTask
        return task
    }
    
    // Новый метод для работы с Decodable объектами
    
    // Видно, что это дженерик, который работает c объектами, поддерживающими протокол Decodable
    // и именно такой объект ожидает в случае успешного запроса в значении .success стандартного перечисления Result
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
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
