//
//  ContentView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

enum HomeTabs {
    case calendar
    case list
    case settings
}

struct ContentView: View {
    @State var selection = HomeTabs.calendar

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                Text("Tab Content 1")
                    .navigationBarTitle("Planner")
            }.tabItem {
                Image(systemName: "calendar")
                Text("Planner")
            }.tag(HomeTabs.calendar)
            NavigationView {
                ListView()
                    .navigationBarTitle("Calendar List")
            }.tabItem {
                Image(systemName: "list.bullet")
                Text("List")
            }.tag(HomeTabs.list)
            Text("Tab Content 3").tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }.tag(HomeTabs.settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
