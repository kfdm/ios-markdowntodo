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

struct PlannerView: View {
    @EnvironmentObject var eventStore: EventStore

    // Query
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var overdue: [EKReminder] = []
    @State private var today: [EKReminder] = []

    func loadData() {
        self.eventStore.overdueReminders()
            .receive(on: DispatchQueue.main)
            .assign(to: \.overdue, on: self)
            .store(in: &self.subscriptions)

        self.eventStore.todayReminders()
            .receive(on: DispatchQueue.main)
            .assign(to: \.today, on: self)
            .store(in: &self.subscriptions)
    }

    var body: some View {
        List {
            ReminderGroup(section: "Overdue", reminders: overdue)
            ReminderGroup(section: "Today", reminders: today)
        }
        .listStyle(GroupedListStyle())
        .onAppear(perform: loadData)
    }
}

struct ReminderGroup: View {
    var section: String
    var reminders: [EKReminder]

    var body: some View {
        Section(header: Text(section)) {
            ForEach(reminders) { reminder in
                NavigationLink(destination: ReminderDetail(reminder: reminder)) {
                    ReminderRow(reminder: reminder)
                }
            }
        }
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
