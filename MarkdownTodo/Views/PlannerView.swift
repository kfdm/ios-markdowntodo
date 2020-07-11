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

    var body: some View {
        List {
            Section(header: Text("Overdue")) {
                ForEach(overdue, id: \.calendarItemIdentifier) { reminder in
                    ReminderRow(reminder: reminder)
                }
            }
            Section(header: Text("Today")) {
                Text("test")
            }
        }.onAppear {
            self.eventStore.overdueReminders()
                .receive(on: DispatchQueue.main)
                .sink { (result) in
                    self.overdue = result
                }
                .store(in: &self.subscriptions)

            self.eventStore.todayReminders()
                .receive(on: DispatchQueue.main)
                .sink { (result) in
                    self.today = result
                }
                .store(in: &self.subscriptions)
        }
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
