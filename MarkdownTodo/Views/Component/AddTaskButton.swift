//
//  AddTaskButton.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/10.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

private struct AddTaskSheet: View {
    @State var reminder: EKReminder
    @EnvironmentObject var eventStore: LegacyEventStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        EKReminderEditView(reminder: $reminder)
            .navigationBarTitle("Adding to \(reminder.calendar.title)", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: actionCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: actionSave)
                }
            }
    }

    func actionCancel() {
        presentationMode.wrappedValue.dismiss()
    }

    func actionSave() {
        eventStore.save(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskButton: View {
    @EnvironmentObject var eventStore: LegacyEventStore
    var calendar: EKCalendar

    @State private var isPresenting = false

    var body: some View {
        Button(action: { isPresenting.toggle() }) {
            Image(systemName: "plus")
        }.sheet(isPresented: $isPresenting) {
            NavigationView {
                AddTaskSheet(reminder: eventStore.new(for: calendar))
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
