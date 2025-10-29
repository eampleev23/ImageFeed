//
//  AppErrors.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 29.10.2025.
//

import Foundation
enum AppError: Error, LocalizedError {
    
    // Network errors
    case networkError(description: String)
    case invalidRequest
    case parsingError
    case duplicateRequest
    case unauthorized
    case serverError(statusCode: Int)
    
    // Auth errors
    case authFailed
    case tokenExpired
    case invalidCode
    case authCancelled
    case tokenValidationFailed
    case insufficientScope
    
    // Profile errors
    case profileLoadFailed
    case avatarLoadFailed
    case profileNotFound
    case invalidProfileData
    case avatarNotFound // ← ДОБАВИТЬ: аватар не найден
    case invalidAvatarURL // ← ДОБАВИТЬ: некорректный URL аватара
    
    // UI errors
    case imageLoadFailed
    case viewConfigurationError
    
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
             .invalidProfileData, .avatarNotFound, .invalidAvatarURL: // ← ОБНОВИТЬ
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
        case .avatarNotFound: // ← ДОБАВИТЬ
            return "Аватар не найден"
        case .invalidAvatarURL: // ← ДОБАВИТЬ
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
             .avatarNotFound, .invalidAvatarURL: // ← ОБНОВИТЬ
            return "Попробуйте обновить профиль"
        default:
            return "Попробуйте еще раз"
        }
    }
}
