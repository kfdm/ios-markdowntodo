//
//  EKReminderEditView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct EKReminderEditView: View {
    @Binding var reminder: EKReminder
    var body: some View {
        List {
            Section {
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

                if let created = reminder.creationDate {
                    DateView(date: created)
                        .modifier(LabelModifier(label: "Created"))
                        .foregroundColor(.secondary)
                }

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
                LinkField(url: $reminder.url)
                    .modifier(LabelModifier(label: "URL"))
                MarkdownView(label: "Description", text: $reminder.unwrappedNotes)
            }
        }
    }
}

struct EKReminderEditView_Previews: PreviewProvider {
    static var previews: some View {
        EKReminderEditView(reminder: .constant(.init()))
    }
}
