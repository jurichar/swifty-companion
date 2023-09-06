//
//  FavoriteView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 13/08/2023.
//

import Foundation
import SwiftUI
import CoreData

struct FavoritesView: View {
    @State private var favoriteUsers: [String] = []
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            List(favoriteUsers, id: \.self) { user in
                NavigationLink(destination: DetailedView(login: user, canSearch: false)) {
                    Text(user)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                        .font(.system(.title2, design: .monospaced))
                        .padding(10)
                        .padding(.horizontal, 10)
                }
            }
            .background(Color.init(uiColor: UIColor.secondarySystemBackground))
            .listStyle(PlainListStyle())
        }
        .onAppear(perform: fetchFavoriteUsers)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "house")
                        .symbolRenderingMode(.monochrome)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.primary)
                        .clipped()
                        .font(.body)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func fetchFavoriteUsers() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            favoriteUsers = users.compactMap { $0.login }
        } catch {
            print("Error fetching favorite users: \(error)")
        }
    }
}
