//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

extension View {
    func wrapNavigation(label: String, systemImage: String) -> some View {
        return NavigationLink(destination: self.navigationBarTitle(label)) {
            Label(label, systemImage: systemImage)
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
        .wrapNavigation(label: "Scheduled", systemImage: "clock")
    }
}

struct AgendaView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.agenda

    var body: some View {
        PredicateFetcher(predicate: eventStore.agendaReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .wrapNavigation(label: "Agenda", systemImage: "calendar")
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
        .wrapNavigation(label: "Priority", systemImage: "exclamationmark.triangle")
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
        .wrapNavigation(label: "External", systemImage: "link")
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.calendar

    var body: some View {
        PredicateFetcher(predicate: eventStore.completeReminders()) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .wrapNavigation(label: "Completed", systemImage: "checkmark.seal")
    }
}

struct SelectedDateView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var date: Date
    var body: some View {
        PredicateFetcher(predicate: eventStore.reminders(for: date)) { reminders in
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
        }
        .navigationBarTitle(DateFormatter.shortDate.string(from: date))
    }
}

struct PlannerView: View {
    var body: some View {
        List {
            AgendaView()
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
