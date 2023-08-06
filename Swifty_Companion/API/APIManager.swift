//
//  APIManager.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Foundation

import Combine
class APIManager {
    private var cancellables = Set<AnyCancellable>()
    private var accessToken: String?

    func requestAccessToken(completion: @escaping (Bool) -> Void) {
        let url = "\(APIConstants.baseURL)/oauth/token"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let body = "grant_type=client_credentials&client_id=\(APIConstants.clientUID)&client_secret=\(APIConstants.clientSecret)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] response in
                    self?.accessToken = response.accessToken
                    completion(true)
                  })
            .store(in: &cancellables)
    }
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
        case createdAt = "created_at"
    }
}

extension APIManager {
    func fetchCursus() -> AnyPublisher<[Cursus], Error> {
        guard let token = accessToken else {
            return Fail(error: APIError.invalidToken).eraseToAnyPublisher()
        }
        
        let url = "\(APIConstants.baseURL)/v2/cursus"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Cursus].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

enum APIError: Error {
    case invalidToken
}


