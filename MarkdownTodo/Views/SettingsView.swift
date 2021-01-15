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
            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                Label("System Settings", systemImage: "gear")
            }
            Link(destination: URL(string: "https://github.com/kfdm/ios-markdowntodo")!) {
                Label("Homepage", systemImage: "house")
            }
            Link(destination: URL(string: "https://github.com/kfdm/ios-markdowntodo/issues")!) {
                Label("Issues", systemImage: "ant")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
