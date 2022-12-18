//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import EventKitExtensions
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
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.dueDate
    @State private var reminders = [EKReminder]()

    var body: some View {
        NavigationLabel(label: "Scheduled", systemImage: "clock") {
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                .task {
                    reminders = await store.scheduledReminders()
                }
                .refreshable {
                    reminders = await store.scheduledReminders()
                }
                .onEventStoreChanged {
                    reminders = await store.scheduledReminders()
                }
        }
    }
}

struct AgendaView: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.agenda
    @State private var reminders = [EKReminder]()

    var body: some View {
        NavigationLabel(label: "Agenda", systemImage: "calendar") {
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                .task {
                    reminders = await store.upcomingReminders()
                }
                .refreshable {
                    reminders = await store.upcomingReminders()
                }
                .onEventStoreChanged {
                    reminders = await store.upcomingReminders()
                }
        }
    }
}

struct PriorityView: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.priority
    @State private var reminders = [EKReminder]()

    var body: some View {
        NavigationLabel(label: "Priority", systemImage: "exclamationmark.triangle") {
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                .task {
                    reminders = await store.incomplete().filter { $0.priority > 0 }
                }
                .refreshable {
                    reminders = await store.incomplete().filter { $0.priority > 0 }
                }
                .onEventStoreChanged {
                    reminders = await store.incomplete().filter { $0.priority > 0 }
                }
        }

    }
}

struct ExternalView: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.priority
    @State private var reminders = [EKReminder]()

    var body: some View {
        NavigationLabel(label: "External", systemImage: "link") {
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                .task {
                    reminders = await store.incomplete().filter { $0.hasURL }
                }
                .refreshable {
                    reminders = await store.incomplete().filter { $0.hasURL }
                }
                .onEventStoreChanged {
                    reminders = await store.incomplete().filter { $0.hasURL }
                }
        }

    }
}

struct CompletedView: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.calendar
    @State private var reminders = [EKReminder]()

    var body: some View {
        NavigationLabel(label: "Completed", systemImage: "checkmark.seal") {
            SortedRemindersView(sortBy: $sortBy, reminders: reminders)
                .task {
                    reminders = await store.completed()
                }
                .refreshable {
                    reminders = await store.completed()
                }
                .onEventStoreChanged {
                    reminders = await store.completed()
                }
        }
    }
}

struct SelectedDateView: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State private var sortBy = SortOptions.dueDate
    @State private var reminders = [EKReminder]()

    var date: Date
    var body: some View {
        SortedRemindersView(sortBy: $sortBy, reminders: reminders)
            .navigationBarTitle(DateFormatter.shortDate.string(from: date))
            .task {
                reminders = await store.incomplete(for: date)
            }
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
