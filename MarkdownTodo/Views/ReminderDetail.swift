//
//  ReminderDetail.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct PriorityPicker: View {
    var label: String
    @Binding var priority: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: $priority) {
                ForEach(0..<10) { p in
                    Text("\(p)").tag(p)
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ReminderDetail: View {
    @EnvironmentObject var store: EventStore
    @State var reminder: EKReminder
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: EmptyView()) {
                NameField(label: "Title", value: $reminder.title)
                EKCalendarPicker(calendar: $reminder.calendar)
                PriorityPicker(label: "Priority", priority: $reminder.priority)
            }
            Section(header: Text("Date")) {
                DateView(date: reminder.startDateComponents, whenUnset: "No Start Date")
                    .modifier(LabelModifier(label: "Start Date"))
                    .modifier(
                        QuickDateModifier(
                            navigationBarTitle: "Select Start Date",
                            date: $reminder.startDateComponents,
                            reminder: $reminder))

                DateView(date: reminder.dueDateComponents, whenUnset: "No Due Date")
                    .modifier(LabelModifier(label: "Due Date"))
                    .modifier(
                        QuickDateModifier(
                            navigationBarTitle: "Select Due Date",
                            date: $reminder.dueDateComponents,
                            reminder: $reminder))

                DateView(date: reminder.creationDate!)
                    .modifier(LabelModifier(label: "Created"))
                    .foregroundColor(.secondary)

                if reminder.isCompleted {
                    DateView(date: reminder.completionDate!, whenUnset: "Not completed")
                        .modifier(LabelModifier(label: "Completed"))
                        .foregroundColor(.secondary)
                }

                ForEach(reminder.recurrenceRules ?? []) { rule in
                    Text("\(rule)")
                }
            }
            Section(header: Text("Other")) {
                if let url = reminder.url {
                    Link(url.absoluteString, destination: url)
                }
                MarkdownView(label: "Description", text: $reminder.unwrappedNotes)
            }
            Section {
                Button("Delete", action: deleteAction).buttonStyle(
                    DestructiveButtonStyle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: cancelAction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: saveAction)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(reminder.title)
        .navigationBarBackButtonHidden(true)
    }

    func saveAction() {
        store.save(reminder)
        presentationMode.wrappedValue.dismiss()
    }

    func cancelAction() {
        reminder.reset()
        presentationMode.wrappedValue.dismiss()
    }

    func deleteAction() {
        store.remove(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var store = EventStore()
    static var previews: some View {
        ReminderDetail(reminder: EKReminder())
            .environmentObject(store)
    }
}
