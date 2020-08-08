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

struct PredicateFetcher: View {
    let predicate: NSPredicate

    // Query
    @EnvironmentObject var eventStore: EventStore
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []

    var groups: [Date: [EKReminder]] {
        Dictionary(
            grouping: reminders,
            by: { Calendar.current.startOfDay(for: $0.dueDate) }
        )
    }

    var body: some View {
        List {
            ForEach(groups.keys.sorted { $0 > $1 }, id: \.self) { date in
                Section(header: DateView(date: date)) {
                    ForEach(self.groups[date]!.sorted { $0.dueDate > $1.dueDate }) { reminder in
                        NavigationLink(destination: ReminderDetail(reminder: reminder)) {
                            ReminderRow(reminder: reminder)
                        }
                    }
                }
            }
        }.onAppear(perform: fetch)
    }

    func fetch() {
        self.eventStore.publisher(for: predicate)
            .receive(on: DispatchQueue.main)
            .assign(to: \.reminders, on: self)
            .store(in: &self.subscriptions)
    }
}
