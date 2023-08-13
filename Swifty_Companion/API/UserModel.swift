//
//  UserModel.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Foundation

struct Users : Decodable {
    let login: String
}

struct Coalition: Decodable {
    let color: String
}

struct User: Decodable {
    let id: Int
    let email: String
    let login: String
    let displayname: String
    let phone: String
    let correction_point: Int
    let location: String?
    let wallet: Int
    let image: Image
    let cursus_users: [Cursus_users]
    let campus: [Campus]
    let projects_users: [Projects]
    
    struct Projects: Decodable {
        let project: Project
        let status: String // searching_a_group, finished, in_progress.
        let validated: Bool?
        
        enum CodingKeys: String, CodingKey {
            case project, status
            case validated = "validated?"
        }
        struct Project: Decodable {
            let name: String
        }
    }
    
    struct Image: Decodable {
        let versions: Versions
        
        struct Versions: Decodable {
            let small: String
        }
    }
    
    struct Cursus_users: Decodable {
        let level: Double
        let grade: String?
        let skills: [Skills]
        
        struct Skills: Decodable {
            let name: String
            let level: Double
        }
    }
    
    struct Campus: Decodable {
        let name: String
        let country: String
    }
}

