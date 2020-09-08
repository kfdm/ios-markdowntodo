//
//  AddTaskButton.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/10.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct AddTask: View {
    @Binding var reminder: EKReminder
    @EnvironmentObject var eventStore: EventStore
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section {
                NameField(label: "Title", value: $reminder.title)
                NameValue(label: "Calendar", value: reminder.calendar.title)
                PriorityPicker(label: "Priority", priority: $reminder.priority)
            }
            Section(header: Text("Date")) {
                DateView(date: reminder.startDateComponents, whenUnset: "No Start Date")
                    .modifier(LabelModifier(label: "Start Date"))
                    .modifier(
                        QuickDateModifier(date: $reminder.startDateComponents, reminder: $reminder))

                DateView(date: reminder.dueDateComponents, whenUnset: "No Due Date")
                    .modifier(LabelModifier(label: "Due Date"))
                    .modifier(
                        QuickDateModifier(date: $reminder.dueDateComponents, reminder: $reminder))
            }
            Section(header: Text("Other")) {
                MarkdownView(label: "Description", text: $reminder.notes)
            }
            Section() {
                Button("Save", action: actionSave)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Adding to \(reminder.calendar.title)", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Cancel", action: actionCancel),
            trailing: Button("Add", action: actionSave)
        )
    }

    func actionCancel() {
        presentationMode.wrappedValue.dismiss()
    }

    func actionSave() {
        try? eventStore.save(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskButton: View {
    @EnvironmentObject var eventStore: EventStore
    var calendar: EKCalendar

    @State private var showAddPopup = false

    var body: some View {
        Button(action: { showAddPopup = true }) {
            Image(systemName: "plus")
        }.sheet(isPresented: $showAddPopup) {
            NavigationView {
                AddTask(reminder: .constant(eventStore.new(for: calendar)))
                    .environmentObject(eventStore)
            }
            .navigationViewStyle(StackNavigationViewStyle())

        }
    }
}
