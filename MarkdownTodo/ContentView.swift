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
                PlannerView()
                    .navigationBarTitle("Planner")
            }.tabItem {
                Image(systemName: "calendar")
                Text("Planner")
            }.tag(HomeTabs.calendar)
            NavigationView {
                CalendarListView()
                    .navigationBarTitle("Calendar List")
            }.tabItem {
                Image(systemName: "list.bullet")
                Text("List")
            }.tag(HomeTabs.list)
            NavigationView {
                SettingsView()
                    .navigationBarTitle("Settings")
            }.tabItem {
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
