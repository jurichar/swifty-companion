//
//  DataModel.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import Combine

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

class DataModel : ObservableObject {
    @Published var posts: [Post] = []
    
    var cancellables = Set<AnyCancellable>()
    
    func loadPosts () {
        guard let url = URL(string: "https://api.intra.42.fr/posts") else { return }
    }
}
