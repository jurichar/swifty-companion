//
//  DetailedView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import SwiftUI
import CoreData

struct DetailedView: View {
    var login: String
    var canSearch: Bool = true
    var fromFav: Bool = false
    @State private var user: User?
    @State private var isError: Bool = false
    @State private var searchText: String = ""
    @State private var searchResults: [Users] = []
    @State private var loadedImage: UIImage?
    @State private var coalitionColor: Color = .primary
    @State private var isFavorite: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
                HStack {
                    if self.presentationMode.wrappedValue.isPresented {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .symbolRenderingMode(.monochrome)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.black)
                                .clipped()
                                .font(.title)
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if canSearch {
                        favoriteButton()
                        reloadButton()
                    } else {
                        favoriteToggleButton()
                    }
                }
                ZStack {
                    VStack {
                        searchField()
                        ScrollView {
                            VStack (spacing: 30) {
                                userInfo()
                                userProjects()
//                                userSkills()
                                usersSkills()
                            }
                        }
                    }
                    resultsSearch()
                    Spacer()
                }
            }
        }
        .onAppear {
            loadUserInfo(login: login)
            loadCoalitionColor(login: login)
            checkIfUserIsFavorite(login: login)
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 10)
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedImage = image
                }
            }
        }.resume()
    }
    
    func checkIfUserIsFavorite(login: String) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            isFavorite = !existingUsers.isEmpty
        } catch {
            print("Error checking if user is favorite: \(error)")
        }
    }
    
    func favoriteButton() -> some View {
        NavigationLink(destination: FavoritesView()) {
            Image(systemName: "star")
                .symbolRenderingMode(.monochrome)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
                .clipped()
                .font(.title)
                .padding(.horizontal, 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func favoriteToggleButton() -> some View {
        Button(action: {
            if isFavorite {
                removeUserFromFavorites(login: login)
            } else {
                addUserToFavorites(login: login)
            }
            isFavorite.toggle()
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .symbolRenderingMode(.monochrome)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.yellow)
                .clipped()
                .font(.title)
                .padding(.horizontal, 10)
        }
    }
    
    func addUserToFavorites(login: String) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if existingUsers.isEmpty {
                let newUser = FavoriteUser(context: context)
                newUser.login = login
                try context.save()
            } else {
                print("User already exists in favorites.")
            }
        } catch {
            print("Error saving user to favorites: \(error)")
        }
    }
    
    func removeUserFromFavorites(login: String) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
        } catch {
            print("Error removing user from favorites: \(error)")
        }
    }
    
    func reloadButton() -> some View {
        Button(action: {
            //            print("reload")
            loadUserInfo(login: login)
            loadCoalitionColor(login: login)
        }) {
            Image(systemName: "gobackward")
                .symbolRenderingMode(.monochrome)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(.black)
                .clipped()
                .font(.title)
                .padding(.horizontal, 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func searchField() -> some View {
        VStack {
            if canSearch {
                TextField("Search", text: searchTextBinding)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .clipped()
                    .font(.system(.title2, design: .monospaced))
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 2)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
    }
    
    func resultsSearch() -> some View {
        GeometryReader { geometry in
            VStack {
                if !searchText.isEmpty && !searchResults.isEmpty {
                    List(searchResults, id: \.login) { user in
                        NavigationLink(destination: DetailedView(login: user.login, canSearch: false)) {
                            Text(user.login)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .clipped()
                                .font(.system(.title2, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(Color.white.opacity(0.8))
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .offset(y: 60)
        }
    }
    
    func userCircles() -> some View {
        HStack(spacing: 50) {
            if URL(string: user?.image.versions.small ?? "") != nil {
                Image(uiImage: loadedImage ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3 )
                    .clipShape(Circle())
            }
            Circle()
                .stroke(coalitionColor, lineWidth: 10)
                .frame(width: UIScreen.main.bounds.width / 3 - 10, height: UIScreen.main.bounds.width / 3 - 10)
                .overlay {
                    Text("\(formatter.string(from: NSNumber(value: user?.cursus_users.last?.level ?? 0)) ?? "???")")
                        .font(.system(.title, design: .monospaced))
                }
        }
        .transition(.opacity)
    }
    
    func userInfo() -> some View {
        VStack (spacing: 10){
            Text("\(user?.displayname ?? "???")")
                .font(.system(.title2, design: .monospaced))
            userCircles()
            Text("aka \(user?.login ?? "???") (\(user?.cursus_users.last?.grade ?? "???"))")
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                .font(.system(.body, design: .monospaced))
            Text("\(user?.location ?? "???")")
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                .font(.system(.body, design: .monospaced))
            Text("\(user?.campus.first?.name ?? "???"), \(user?.campus.first?.country ?? "???")")
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                .font(.system(.body, design: .monospaced))
            Text("\(user?.phone ?? "?? ?? ?? ?? ??")")
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                .font(.system(.body, design: .monospaced))
            Text("\(user?.correction_point ?? 0) correction points - \(user?.wallet ?? 0) wallet ")
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
                .font(.system(.body, design: .monospaced))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .padding()
        .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color(.systemBackground)))
        .padding(.horizontal, 10)
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 2)
    }
    
    func statusIcon(for project: User.Projects?) -> some View {
        guard let project = project else {
            return Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.gray)
        }
        
        switch project.status {
        case "finished":
            if project.validated == true {
                return Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                return Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        case "in progress":
            return Image(systemName: "hourglass")
                .foregroundColor(.yellow)
        case "searching_a_group":
            return Image(systemName: "magnifyingglass.circle.fill")
                .foregroundColor(.blue)
        default:
            return Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.gray)
        }
    }
    
    func userProjects() -> some View {
        VStack {
            Text("Projects")
                .font(.system(.title3, design: .monospaced))
            ScrollView {
                VStack {
                    ForEach(0..<(user?.projects_users.count ?? 0), id: \.self) { index in
                        HStack {
                            Text(user?.projects_users[index].project.name ?? "Unknown")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(.body, design: .monospaced))
                            statusIcon(for: user?.projects_users[index])
                        }
                        .clipped()
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
            .padding()
            .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color(.systemBackground)))
        }
        .frame(height: UIScreen.main.bounds.width / 2 + 40)
        .padding(.horizontal, 10)
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 2)
    }
    
//    func userSkills() -> some View {
//        VStack {
//            Text("Skills")
//                .font(.system(.title3, design: .monospaced))
//            ScrollView {
//                VStack {
//                    if (user?.cursus_users.last?.skills.isEmpty ?? true) {
//                        Text("No skills")
//                            .foregroundColor(.secondary)
//                            .font(.system(.headline, design: .monospaced))
//                    } else {
//                        ForEach(0..<(user?.cursus_users.last?.skills.count ?? 0), id: \.self) { index in
//                            HStack {
//                                Text(user?.cursus_users.last?.skills[index].name ?? "")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .font(.system(.body, design: .monospaced))
//                                Text("\(formatter.string(from: NSNumber(value: user?.cursus_users.last?.skills[index].level ?? 0)) ?? "???")")
//                                    .frame(width: 100, alignment: .trailing)
//                                    .font(.system(.body, design: .monospaced))
//                            }
//                            .clipped()
//                            Divider()
//                        }
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .clipped()
//            .padding()
//            .background {
//                RoundedRectangle(cornerRadius: 15, style: .continuous)
//                    .stroke(Color(.quaternaryLabel), lineWidth: 2)
//                    .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color(.systemBackground)))
//            }
//        }
//        .frame(height: UIScreen.main.bounds.width / 2 + 40)
//        .padding(.horizontal, 10)
//        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
//    }
    
    func loadUserInfo(login: String) {
        APIManager.shared.fetchUserInfo(for: login) { (result) in
            switch result {
            case .success(let fetchedUser):
                DispatchQueue.main.async {
                    self.user = fetchedUser
                    if let imageUrl = URL(string: fetchedUser.image.versions.small) {
                        self.loadImage(from: imageUrl)
                    }
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
    func loadCoalitionColor(login: String) {
        APIManager.shared.fetchCoalitionColor(for: login) { result in
            switch result {
            case .success(let colorString):
                DispatchQueue.main.async {
                    self.coalitionColor = Color(hex: colorString)
                }
            case .failure(let error):
                print("Error fetching coalition color: \(error)")
            }
        }
    }
    
    func usersSkills() -> some View {
        let skillsData = user?.cursus_users.last?.skills.map { Skill(name: $0.name, level: $0.level) } ?? []
        return VStack {
            Text("Skills")
                .font(.system(.title3, design: .monospaced))
                    RadarView(skills: skillsData)
                        .frame(height: UIScreen.main.bounds.width)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color(.systemBackground)))
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 2)
        }
        .padding(.horizontal, 10)
    }
}

struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedView(login: "jurichar")
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
}

// convert color from HEX to ARGB
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
