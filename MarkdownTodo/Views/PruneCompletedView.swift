//
//  PruneCompletedView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/22.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct PruneListView: View {
    var reminders: [EKReminder]
    @EnvironmentObject var store: EventStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(reminders) { reminder in
                ReminderRow(reminder: reminder)
            }
        }
        .navigationBarTitle("Prune Completed \(reminders.count)")
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Prune", action: actionPrune)
            }
        }
    }

    init(reminders: [EKReminder]) {
        let cuttoff = Calendar.current.date(byAdding: .month, value: -1, to: .init())
        self.reminders =
            reminders
            .filter { $0.isCompleted }
            // Show only completions more than cuttoff ago
            .filter { $0.completionDate! < cuttoff! }
            // Sort Descending
            .sorted { $0.completionDate! > $1.completionDate! }
    }

    func actionPrune() {
        print("Prunning \(reminders)")
        store.remove(reminders)
        presentationMode.wrappedValue.dismiss()
    }
}

struct PruneCompletedButton: View {
    var calendar: EKCalendar
    @State private var isPresented = false
    @EnvironmentObject var store: EventStore

    var body: some View {
        Button("Prune Completed", action: actionToggleSheet)
            .sheet(isPresented: $isPresented) {
                NavigationView {
                    PredicateFetcher(predicate: store.completed(for: calendar)) { reminders in
                        PruneListView(reminders: reminders)
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: actionToggleSheet)
                        }
                    }
                }
            }
    }

    func actionToggleSheet() {
        isPresented.toggle()
    }
}

//struct PruneCompletedView_Previews: PreviewProvider {
//    static var previews: some View {
//        PruneCompletedView()
//    }
//}
