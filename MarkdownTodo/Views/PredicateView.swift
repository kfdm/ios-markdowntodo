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

struct PredicateView: View {
    let predicate: NSPredicate

    // Query
    @EnvironmentObject var eventStore: EventStore
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []

    var body: some View {
        List {
            ForEach(reminders) { reminder in
                NavigationLink(destination: ReminderDetail(reminder: reminder)) {
                    ReminderRow(reminder: reminder)
                }  //.isDetailLink(false)
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
