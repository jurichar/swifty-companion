//
//  DetailedView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import SwiftUI

struct DetailedView: View {
    var login: String
    var canSearch: Bool = true
    @State private var user: User?
    @State private var isError: Bool = false
    @State private var uiImage: UIImage? = nil
    @State private var searchText: String = ""
    @State private var searchResults: [Users] = []

    var searchTextBinding: Binding<String> {
        Binding<String>(
            get: { self.searchText },
            set: {
                self.searchText = $0
                self.performSearch()
            }
        )
    }
    
    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    
    var body: some View {
        NavigationView {
        VStack {
            Group {
                Button(action: {
                    print ("reload")
                }) {
                    Image(systemName: "gobackward")
                        .symbolRenderingMode(.monochrome)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .clipped()
                        .font(.title2)
                        .padding()
                        .padding(.horizontal, 10)
                }
            }
            Group {
                if canSearch {
                TextField("Search", text: searchTextBinding)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding()
                    .padding(.horizontal)
                }
                if !searchText.isEmpty {
                    ScrollView() {
                        VStack {
                            ForEach(searchResults, id: \.login) { user in
                                HStack {
                                    NavigationLink(destination: DetailedView(login: user.login, canSearch: false)) {
                                        HStack {
                                            Text(user.login)
                                                .frame(maxWidth: .infinity)
                                                .clipped()
                                                .font(.system(.title2, design: .monospaced))
                                                .foregroundColor(.black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                Text("\(user?.displayname ?? "Loading...")")
                    .font(.system(.title, design: .monospaced))
                HStack {
                    Circle()
                        .stroke(.primary, lineWidth: 20)
                        .background(Circle().fill(.clear))
                        .overlay {
                            Text("\(user?.image.versions.small ?? "no picture")")
                                .font(.system(.body, design: .monospaced))
                        }
                    Circle()
                        .stroke(.primary, lineWidth: 20)
                        .background(Circle().fill(.clear))
                        .overlay {
                            Text("\(formatter.string(from: NSNumber(value: user?.cursus_users.last?.level ?? 0)) ?? "")").font(.system(.largeTitle, design: .monospaced))
                        }
                }
                Text("aka \(user?.login ?? "...")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("\(user?.location ?? "unavailable")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("\(user?.campus.first?.name ?? "campus"), \(user?.campus.first?.country ?? "campus")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("\(user?.phone ?? "XX XX XX XX XX")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("\(user?.correction_point ?? 0) correction points - \(user?.wallet ?? 0) wallet ")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
            }
            Group {
                Text("Projects")
                Rectangle()
                    .stroke(.primary, lineWidth: 1)
                    .background(Rectangle().fill(.clear))
                    .overlay(alignment: .leading) {
                        ScrollView {
                            VStack {
                                ForEach(1..<10) { index in
                                    HStack(spacing: 150) {
                                        Text("\(user?.projects_users[index].project.name ?? "10") - \(user?.projects_users[index].status ?? "10")")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                }
                            }
                        }
                    }
                Text("Skills")
                Rectangle()
                    .stroke(.primary, lineWidth: 1)
                    .background(Rectangle().fill(.clear))
                    .overlay(alignment: .leading) {
                        ScrollView {
                            VStack {
                                ForEach(0..<10) { index in
                                    Text("\(user?.cursus_users.last?.skills[index].name ?? "name") - \(user?.cursus_users.last?.skills[index].level ?? 0)")
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                }
                            }
                        }
                        .padding(.bottom, 5)
                    }
            }
        }
    }
        .onAppear {
            loadUserInfo(login: login)
        }
    }
    
    func loadUserInfo(login: String) {
        APIManager.shared.fetchUserInfo(for: login) { (result) in
            print (result)
            switch result {
            case .success(let fetchedUser):
                DispatchQueue.main.async {
                    self.user = fetchedUser
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isError = true
                    print("Error fetching user info: \(error)")
                }
            }
        }
    }
    
    func performSearch() {
        if searchText.isEmpty || searchText.count < 3 {
            searchResults = []
            return
        }
        APIManager.shared.fetchUsers(prefix: searchText) { result in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.searchResults = users
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching users: \(error)")
                }
            }
        }
    }
}

struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedView(login: "jurichar")
    }
}
