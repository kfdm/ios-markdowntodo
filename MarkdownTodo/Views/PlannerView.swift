//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct UpcomingView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.upcomingReminders(days: 7), sortBy: $sortBy)
            .navigationBarTitle("Upcoming")
    }
}

struct TodayView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.overdueReminders(), sortBy: $sortBy)
            .navigationBarTitle("Today")
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.completeReminders(), sortBy: $sortBy)
            .navigationBarTitle("Completed")
    }
}

struct SelectedDateView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var date: Date
    var body: some View {
        PredicateFetcher(predicate: eventStore.reminders(for: date), sortBy: $sortBy)
            .navigationBarTitle(DateFormatter.shortDate.string(from: date))
    }
}

struct PlannerView: View {
    var body: some View {
        List {
            NavigationLink("Today", destination: TodayView())
            NavigationLink("Upcoming", destination: UpcomingView())
            CalendarOverview()
            NavigationLink("Completed", destination: CompletedView())
        }
        .listStyle(GroupedListStyle())
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
