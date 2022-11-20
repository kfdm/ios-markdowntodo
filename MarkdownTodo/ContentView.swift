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

fileprivate extension View {
    func tagLabel(_ label: String, systemImage: String, tab: HomeTabs) -> some View {
        self
            .tag(tab)
            .tabItem {
                Label(label, systemImage: systemImage)
            }
    }
}

struct ContentView: View {
    @State var selection = HomeTabs.calendar
    @EnvironmentObject var eventStore: LegacyEventStore
    @Environment(\.scenePhase) var scenePhase

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
            .onAppear {
                print(eventStore.authorized)
            }

        }


        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                eventStore.checkAccess()
                eventStore.refreshSourcesIfNecessary()
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
