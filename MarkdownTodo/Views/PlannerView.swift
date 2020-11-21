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
        PredicateFetcher(predicate: eventStore.scheduledReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .wrapNavigation(icon: "clock", label: "Scheduled")
    }
}

struct TodayView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.agenda

    var body: some View {
        PredicateFetcher(predicate: eventStore.overdueReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .wrapNavigation(icon: "calendar", label: "Today")
    }
}

struct PriorityView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.priority

    var body: some View {
        PredicateFetcher(predicate: eventStore.incompleteReminders()) { reminders in
            SortedRemindersView(
                sortBy: $sortBy, reminders: reminders.filter { $0.priority > 0 })
        }
        .wrapNavigation(icon: "exclamationmark.triangle", label: "Priority")
    }
}

struct ExternalView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.priority

    var body: some View {
        PredicateFetcher(predicate: eventStore.incompleteReminders()) { reminders in
            SortedRemindersView(
                sortBy: $sortBy, reminders: reminders.filter { $0.hasURL })
        }
        .wrapNavigation(icon: "link", label: "External")
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.calendar

    var body: some View {
        PredicateFetcher(predicate: eventStore.completeReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .wrapNavigation(icon: "checkmark.seal", label: "Completed")
    }
}

struct SelectedDateView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var date: Date
    var body: some View {
        PredicateFetcher(predicate: eventStore.incompleteReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .navigationBarTitle(DateFormatter.shortDate.string(from: date))
    }
}

struct PlannerView: View {
    var body: some View {
        List {
            TodayView()
            ScheduledView()
            PriorityView()
            ExternalView()
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
