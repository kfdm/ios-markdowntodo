//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct NavigationLabel<Destination: View>: View {
    var label: String
    var systemImage: String
    var destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination().navigationTitle(label)) {
            Label(label, systemImage: systemImage)
        }
    }
}

struct ScheduledView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.dueDate

    var body: some View {
        NavigationLabel(label: "Scheduled", systemImage: "clock") {
            PredicateFetcher(predicate: eventStore.scheduledReminders()) { reminders in
                SortedRemindersView(sortBy: $sortBy, reminders: reminders)
            }
        }
    }
}

struct AgendaView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.agenda

    var body: some View {
        NavigationLabel(label: "Agenda", systemImage: "calendar") {
            PredicateFetcher(predicate: eventStore.upcomingReminders()) { reminders in
                SortedRemindersView(sortBy: $sortBy, reminders: reminders)
            }
        }
    }
}

struct PriorityView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.priority

    var body: some View {
        NavigationLabel(label: "Priority", systemImage: "exclamationmark.triangle") {
            PredicateFetcher(predicate: eventStore.incompleteReminders()) { reminders in
                SortedRemindersView(
                    sortBy: $sortBy, reminders: reminders.filter { $0.priority > 0 })
            }
        }
    }
}

struct ExternalView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.priority

    var body: some View {
        NavigationLabel(label: "External", systemImage: "link") {
            PredicateFetcher(predicate: eventStore.incompleteReminders()) { reminders in
                SortedRemindersView(
                    sortBy: $sortBy, reminders: reminders.filter { $0.hasURL })
            }
        }
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore
    @State private var sortBy = SortOptions.calendar

    var body: some View {
        NavigationLabel(label: "Completed", systemImage: "checkmark.seal") {
            PredicateFetcher(predicate: eventStore.completeReminders()) { reminders in
                SortedRemindersView(sortBy: $sortBy, reminders: reminders)
            }
        }
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
