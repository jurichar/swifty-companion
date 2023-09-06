//
//  APIToken.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Foundation

struct APIToken : Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
    let createdAt: Int
    let secretValidUntil: Int
}
