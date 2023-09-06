//
//  LoginView.swift
//  Swifty_Companion
//
//  Created by Julien Richard on 06/08/2023.
//

import SwiftUI

struct Untitled: View {
    var body: some View {
        VStack {
            Group {
                Image(systemName: "gobackward")
                    .symbolRenderingMode(.monochrome)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .clipped()
                    .font(.title2)
                Text("search")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.headline, design: .monospaced))
                Rectangle()
                    .frame(height: 1)
                    .clipped()
                Text("Julien RICHARD")
                    .font(.system(.title, design: .monospaced))
                HStack {
                    Circle()
                    Circle()
                }
                Text("aka jurichar")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("aka jurichar")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("aka jurichar")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("aka jurichar")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipped()
                    .font(.system(.body, design: .monospaced))
                Text("aka jurichar")
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
                                ForEach(0..<5) { _ in // Replace with your data model here
                                    HStack(spacing: 250) {
                                        Text("ft_project")
                                        Text("100")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .padding()
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
                                ForEach(0..<5) { _ in // Replace with your data model here
                                    HStack(spacing: 250) {
                                        Text("ft_project")
                                        Text("100")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .padding()
                                }
                            }
                        }
                    }
            }
        }
    }
}

struct Untitled_Previews: PreviewProvider {
    static var previews: some View {
        Untitled()
    }
}
