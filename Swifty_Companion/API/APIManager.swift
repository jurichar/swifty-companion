//
//  APIManager.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    var currentToken : String?
    
    func fetchToken() {
        // Création de l'URL avec les paramètres de requête
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/oauth/token")!
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),
            URLQueryItem(name: "client_id", value: APIConstants.UID),
            URLQueryItem(name: "client_secret", value: APIConstants.secret)
        ]
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase // Pour gérer le format en snake_case du JSON
                let apiToken = try decoder.decode(APIToken.self, from: data)
                self.currentToken = apiToken.accessToken
                print(apiToken.accessToken)
            } catch {
                print("Failed to decode APIToken: \(error)")
            }
        }.resume()
    }
    
    func fetchUserInfo(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = currentToken else {
            print("error in fetchUserInfo")
            completion(.failure(NSError(domain: "com.Swift_Companion", code: -2, userInfo: ["message": "Token not found"])))
            return
        }
        
        let url = URL(string: "\(APIConstants.baseURL)/v2/users/jurichar")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "com.Swift_Companion", code: -3, userInfo: nil)))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
            
        }.resume()
    }
    
    func generateRangeValue(for prefix: String) -> String {
        // Convertir le dernier caractère en Unicode scalar pour pouvoir l'incrémenter
        guard let lastChar = prefix.last, let scalar = UnicodeScalar(String(lastChar)) else {
            return "\(prefix),z\(prefix)"
        }
        
        // Incrémenter le dernier caractère
        let incrementedChar = Character(UnicodeScalar(scalar.value + 1)!)
        
        // Construire la nouvelle chaîne
        let newString = prefix.dropLast() + String(incrementedChar)
        
        return "\(prefix),\(newString)"
    }

    func fetchUsers(prefix: String, completion: @escaping (Result<[Users], Error>) -> Void) {
        guard let token = currentToken else {
            print("error in fetchUsersStartingWith")
            completion(.failure(NSError(domain: "com.Swift_Companion", code: -2, userInfo: ["message": "Token not found"])))
            return
        }
        
        let rangeValue = generateRangeValue(for: prefix)
        var urlComponents = URLComponents(string: "\(APIConstants.baseURL)/v2/users")!
        urlComponents.queryItems = [
            URLQueryItem(name: "range[login]", value: rangeValue)
        ]
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "com.Swift_Companion", code: -3, userInfo: nil)))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([Users].self, from: data)
                print(String(data: data, encoding: .utf8) ?? "Invalid data")
                completion(.success(users))
            } catch let jsonError {
                completion(.failure(jsonError))
            }
            
        }.resume()
    }
}
