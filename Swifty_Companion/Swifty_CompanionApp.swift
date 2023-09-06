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
    init() {
        APIManager.shared.fetchToken()
    }

    var body: some Scene {
        WindowGroup {
            DetailedView(login: "jurichar")
        }
    }
}
