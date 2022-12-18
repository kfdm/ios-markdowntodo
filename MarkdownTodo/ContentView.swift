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

extension View {
    fileprivate func tagLabel(_ label: String, systemImage: String, tab: HomeTabs) -> some View {
        self
            .tag(tab)
            .tabItem {
                Label(label, systemImage: systemImage)
            }
    }
}

struct ContentView: View {
    @State var selection = HomeTabs.calendar
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var store: MarkdownEventStore

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                PlannerView()
                    .navigationBarTitle("Planner")
            }
            .tagLabel("Planner", systemImage: "calendar", tab: .calendar)
            .navigationViewStyle(DoubleColumnNavigationViewStyle())

            NavigationView {
                CalendarListView()
                    .navigationBarTitle("Calendar List")
            }
            .tagLabel("List", systemImage: "list.bullet", tab: .list)
            .navigationViewStyle(DoubleColumnNavigationViewStyle())

            NavigationView {
                SettingsView()
                    .navigationBarTitle("Settings")
            }
            .tagLabel("Settings", systemImage: "gear", tab: .settings)
            .navigationViewStyle(DoubleColumnNavigationViewStyle())

        }

        .onChange(of: scenePhase) { phase in
            print("Checking phase \(scenePhase) \(store.authorized)")
            switch phase {
            case .active:
                store.refreshSourcesIfNecessary()
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
