//
//  PredicateView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct RemindersGroupDate<ReminderView>: View where ReminderView: View {
    let reminders: [Date: [EKReminder]]
    let content: (EKReminder) -> ReminderView

    var body: some View {
        List {
            // Show dates oldest to newest
            ForEach(reminders.keys.sorted { $0 < $1 }, id: \.self) { date in
                Section(header: DateView(date: date, whenUnset: "No Due Date", formatter: .date)) {
                    ForEach(reminders[date]!.sorted { $0.dueDate < $1.dueDate }) { reminder in
                        content(reminder)
                    }
                }
            }
        }
    }
}

struct RemindersGroupPriority<ReminderView>: View where ReminderView: View {
    let reminders: [Int: [EKReminder]]
    let content: (EKReminder) -> ReminderView

    var body: some View {
        List {
            ForEach(reminders.keys.sorted { $0 < $1 }, id: \.self) { priority in
                Section(header: Text("Priority \(priority)")) {
                    ForEach(self.reminders[priority]!.sorted { $0.dueDate < $1.dueDate }) {
                        reminder in
                        content(reminder)
                    }
                }
            }
        }
    }
}

struct RemindersGroupTitle<ReminderView>: View where ReminderView: View {
    let reminders: [EKReminder]
    let content: (EKReminder) -> ReminderView

    var body: some View {
        List {
            ForEach(reminders.sorted { $0.title > $1.title }) { reminder in
                content(reminder)
            }
        }
    }
}

struct PredicateFetcher: View {
    let predicate: NSPredicate

    // Query
    @EnvironmentObject var eventStore: EventStore
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []
    @State private var sortBy = SortOptions.dueDate

    func content(for reminder: EKReminder) -> some View {
        return NavigationLink(destination: ReminderDetail(reminder: reminder)) {
            ReminderRow(reminder: reminder)
        }
    }

    var body: some View {
        Group {
            switch sortBy {
            case .dueDate:
                RemindersGroupDate(reminders: reminders.byDueDate(), content: content)
            case .createdDate:
                RemindersGroupDate(reminders: reminders.byCreateDate(), content: content)
            case .priority:
                RemindersGroupPriority(reminders: reminders.byPriority(), content: content)
            case .title:
                RemindersGroupTitle(reminders: reminders, content: content)
            }
        }
        .onAppear(perform: fetch)
        .navigationBarItems(
            trailing: HStack {
                SortButton(sortBy: $sortBy)
            })
    }

    func fetch() {
        self.eventStore.publisher(for: predicate)
            .receive(on: DispatchQueue.main)
            .assign(to: \.reminders, on: self)
            .store(in: &self.subscriptions)
    }
}
