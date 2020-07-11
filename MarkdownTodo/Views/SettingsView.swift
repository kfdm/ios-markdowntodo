//
//  SettingsView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Link("Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
            Link("Github", destination: URL(string: "https://github.com")!)
        }.listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct Link: View {
    var label: String
    var destination: URL

    var body: some View {
        Button(action: openLink) {
            Text(label)
        }
    }
    func openLink() {
        UIApplication.shared.open(destination)
    }
}
extension Link {
    init(_ label: String, destination: URL) {
        self.label = label
        self.destination = destination
    }
}
