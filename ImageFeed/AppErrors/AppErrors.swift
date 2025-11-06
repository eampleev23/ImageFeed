//
//  AppErrors.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 29.10.2025.
//

import Foundation
enum AppError: Error, LocalizedError {
    
    //MARK: - Network
    
    case networkError(description: String)
    case invalidRequest
    case parsingError
    case duplicateRequest
    case unauthorized
    case serverError(statusCode: Int)
    
    //MARK: - Auth
    
    case authFailed
    case tokenExpired
    case invalidCode
    case authCancelled
    case tokenValidationFailed
    case insufficientScope
    
    //MARK: - Profile
    
    case profileLoadFailed
    case avatarLoadFailed
    case profileNotFound
    case invalidProfileData
    case avatarNotFound
    case invalidAvatarURL
    
    //MARK: - UI
    
    case imageLoadFailed
    case viewConfigurationError
    
    //MARK: - Computed properties
    
    var isNetworkError: Bool {
        switch self {
        case .networkError, .invalidRequest, .unauthorized, .serverError:
            return true
        default:
            return false
        }
    }
    
    var isAuthError: Bool {
        switch self {
        case .authFailed, .tokenExpired, .invalidCode, .authCancelled,
                .unauthorized, .tokenValidationFailed, .insufficientScope:
            return true
        default:
            return false
        }
    }
    
    var isProfileError: Bool {
        switch self {
        case .profileLoadFailed, .avatarLoadFailed, .profileNotFound,
                .invalidProfileData, .avatarNotFound, .invalidAvatarURL:
            return true
        default:
            return false
        }
    }
    
    var statusCode: Int? {
        if case .serverError(let code) = self {
            return code
        }
        return nil
    }
    
    //MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let description):
            return "Ошибка сети: \(description)"
        case .invalidRequest:
            return "Неверный запрос"
        case .parsingError:
            return "Ошибка обработки данных"
        case .duplicateRequest:
            return "Повторный запрос"
        case .unauthorized:
            return "Требуется авторизация"
        case .serverError(let statusCode):
            switch statusCode {
            case 400:
                return "Неверный запрос к серверу"
            case 401:
                return "Требуется авторизация"
            case 403:
                return "Доступ запрещен"
            case 404:
                return "Ресурс не найден"
            case 500:
                return "Внутренняя ошибка сервера"
            case 502:
                return "Сервер временно недоступен"
            case 503:
                return "Сервис временно недоступен"
            default:
                return "Ошибка сервера: \(statusCode)"
            }
        case .authFailed:
            return "Не удалось войти в систему"
        case .tokenExpired:
            return "Срок действия токена истек"
        case .invalidCode:
            return "Неверный код авторизации"
        case .authCancelled:
            return "Авторизация отменена"
        case .tokenValidationFailed:
            return "Ошибка проверки токена"
        case .insufficientScope:
            return "Недостаточно прав доступа"
        case .profileLoadFailed:
            return "Не удалось загрузить профиль"
        case .avatarLoadFailed:
            return "Не удалось загрузить аватар"
        case .profileNotFound:
            return "Профиль не найден"
        case .invalidProfileData:
            return "Некорректные данные профиля"
        case .avatarNotFound:
            return "Аватар не найден"
        case .invalidAvatarURL:
            return "Некорректная ссылка на аватар"
        case .imageLoadFailed:
            return "Не удалось загрузить изображение"
        case .viewConfigurationError:
            return "Ошибка настройки интерфейса"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Проверьте подключение к интернету и попробуйте снова"
        case .serverError(let statusCode):
            switch statusCode {
            case 400...499:
                return "Проверьте правильность запроса"
            case 500...599:
                return "Проблема на стороне сервера, попробуйте позже"
            default:
                return "Попробуйте еще раз"
            }
        case .unauthorized, .authFailed, .tokenExpired, .tokenValidationFailed:
            return "Войдите в систему заново"
        case .duplicateRequest:
            return "Подождите завершения предыдущего запроса"
        case .parsingError:
            return "Попробуйте обновить данные"
        case .authCancelled:
            return "Попробуйте войти снова"
        case .invalidCode:
            return "Проверьте правильность кода авторизации"
        case .insufficientScope:
            return "Обратитесь к администратору для получения прав доступа"
        case .profileLoadFailed, .avatarLoadFailed, .profileNotFound, .invalidProfileData,
                .avatarNotFound, .invalidAvatarURL:
            return "Попробуйте обновить профиль"
        default:
            return "Попробуйте еще раз"
        }
    }
    
    // MARK: - Private helpers
    
    func serverMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400: return "Неверный запрос к серверу"
        case 401: return "Требуется авторизация"
        case 403: return "Доступ запрещён"
        case 404: return "Ресурс не найден"
        case 500: return "Внутренняя ошибка сервера"
        case 502: return "Сервер временно недоступен"
        case 503: return "Сервис временно недоступен"
        default:  return "Ошибка сервера: \(statusCode)"
        }
    }
    
    func serverRecovery(for statusCode: Int) -> String {
        switch statusCode {
        case 400...499: return "Проверьте правильность запроса."
        case 500...599: return "Проблема на стороне сервера, попробуйте позже."
        default: return "Попробуйте ещё раз."
        }
    }
    
}
