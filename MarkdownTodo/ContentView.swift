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
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                PlannerView()
                    .navigationBarTitle("Planner")
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .tag(HomeTabs.calendar)
            .tabItem {
                Image(systemName: "calendar")
                Text("Planner")
            }

            NavigationView {
                CalendarListView()
                    .navigationBarTitle("Calendar List")
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .tag(HomeTabs.list)
            .tabItem {
                Image(systemName: "list.bullet")
                Text("List")
            }

            NavigationView {
                SettingsView()
                    .navigationBarTitle("Settings")
            }
            .tag(HomeTabs.settings)
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }.onAppear(perform: eventStore.checkAccess)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
