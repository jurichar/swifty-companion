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
        .onAppear(perform: fetchFavoriteUsers)
        .navigationBarBackButtonHidden(true)
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button(action: {
                         self.presentationMode.wrappedValue.dismiss()
                     }) {
                         Image(systemName: "house")
                             .foregroundColor(.black)
                     }
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
