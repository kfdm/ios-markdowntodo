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
