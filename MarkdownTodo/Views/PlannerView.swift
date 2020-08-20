//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

extension View {
    func wrapNavigation(icon: String, label: String) -> some View {
        return NavigationLink(destination: self.navigationBarTitle(label)) {
            Image(systemName: icon)
            Text(label)
        }
    }
}

struct ScheduledView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.scheduledReminders(), sortBy: $sortBy)
            .wrapNavigation(icon: "clock", label: "Scheduled")
    }
}

struct TodayView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.overdueReminders(), sortBy: $sortBy)
            .wrapNavigation(icon: "calendar", label: "Today")
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        PredicateFetcher(predicate: eventStore.completeReminders(), sortBy: $sortBy)
            .wrapNavigation(icon: "checkmark.seal", label: "Completed")
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
            TodayView()
            ScheduledView()
            CalendarOverview()
            CompletedView()
        }
        .listStyle(GroupedListStyle())
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
