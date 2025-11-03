//
//  Profile.swift
//  ImageFeed
//
//  Created by Евгений Амплеев on 29.10.2025.
//

import Foundation

struct ProfileImage: Decodable {
    let large: String
}

struct Profile {
    let userName: String?
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        
    }
}
