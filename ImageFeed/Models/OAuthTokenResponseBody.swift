//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 20.10.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    var accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
