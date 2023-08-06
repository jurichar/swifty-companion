//
//  APIConstants.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Foundation
struct APIConstants {
    static let baseURL = "https://api.intra.42.fr"
    static let clientUID = "Your application uid"
    static let clientSecret = "Your secret token"
}

struct Cursus: Codable {
    let id: Int
    let createdAt: Date
    let name: String
    let slug: String
    let usersCount: Int
    let usersURL: String
    let projectsURL: String
    let topicsURL: String
}
