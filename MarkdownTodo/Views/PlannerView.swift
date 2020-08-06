//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct UpcomingView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateView(predicate: eventStore.todayReminders())
            .navigationBarTitle("Upcomgin")
    }
}

struct OverdueView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateView(predicate: eventStore.overdueReminders())
            .navigationBarTitle("Overdue")
    }
}

struct PlannerView: View {
    var body: some View {
        List {
            Text("Calendar Placeholder")
                .frame(height: 256)
            NavigationLink("Overdue", destination: OverdueView())
            NavigationLink("Upcoming", destination: UpcomingView())
        }
        .listStyle(GroupedListStyle())
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
