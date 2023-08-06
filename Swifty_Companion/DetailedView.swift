//
//  DetailedView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import SwiftUI

struct DetailedView: View {
    var body: some View {
        VStack(spacing: 100) {
            VStack {
                Text("Swifty Companion")
                    .font(.system(.largeTitle, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            VStack(spacing: 30) {
                Text("Login with 42")
                    .font(.system(.title, design: .monospaced))
                Circle()
                    .frame(width: 100)
                    .clipped()
            }
        }
        .padding(0)
    }
}

struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedView()
    }
}
