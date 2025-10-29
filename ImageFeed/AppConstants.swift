//
//  Constants.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 16.10.2025.
//

import Foundation
enum AppConstants {
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let authBaseURL = URL(string: "https://unsplash.com")!
    
    static let accessKey = "X-1eXvB7L_d_xxtcNznixBqMP1iAY1_5uqxsowou_Ps"
    static let secretKey = "atBFyx3l0uQtulX81FccgPgSRT1StNUgX7gIBTvtIzQ"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let barerTokenKey = "bearerToken"
    
    static var getAuthTokenURL: URL {
        return authBaseURL.appendingPathComponent("/oauth/token")
    }
    
    static var authorizeURL: URL {
        return authBaseURL.appendingPathComponent("/oauth/authorize")
    }
    
    static var getUserURL: URL {
        return defaultBaseURL.appendingPathComponent("/users/")
    }
    
    static var getUserAvatarURL: URL {
        return defaultBaseURL.appendingPathComponent("/me")
    }
    
    static var photosURL: URL {
        return defaultBaseURL.appendingPathComponent("/photos")
    }
    
    static func getPhotosURL(page: Int, perPage: Int = 10) -> URL? {
        var components = URLComponents(url: photosURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        return components?.url
    }
    
    
}
