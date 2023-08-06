//
//  Swifty_CompanionApp.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 04/08/2023.
//

import SwiftUI
import Combine

@main
struct Swifty_CompanionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
