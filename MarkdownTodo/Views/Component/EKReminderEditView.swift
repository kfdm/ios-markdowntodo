//
//  EKReminderEditView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI
import swift_markdown_editor

struct EKReminderEditView: View {
    @Binding var reminder: EKReminder
    @State var showFull = false
    var body: some View {
        Group {
            if showFull {
                EKReminderEditViewFull(reminder: $reminder)
            } else {
                EKReminderEditViewSimple(reminder: $reminder)
            }
        }.toolbar {
            Toggle("Detail", isOn: $showFull)
        }
    }
}

struct EKReminderEditViewSimple: View {
    @Binding var reminder: EKReminder
    var body: some View {
        List {
            TextField("Title", text: $reminder.title)
            MarkdownEditor(text: $reminder.unwrappedNotes)
                .frame(minHeight: 500, maxHeight: .infinity)
        }
    }
}

struct EKReminderEditViewFull: View {
    @Binding var reminder: EKReminder
    var body: some View {
        List {
            Section {
                TextField("Title", text: $reminder.title)
            }
            Section(header: Text("Detail")) {
                EKCalendarPicker(calendar: $reminder.calendar)
                PriorityPicker(label: "Priority", priority: $reminder.priority)
                QuickDatePicker(label: "Start Date", date: $reminder.startDateComponents)
                    .modifier(LabelModifier(label: "Start Date"))
                QuickDatePicker(label: "Due Date", date: $reminder.dueDateComponents)
                    .modifier(LabelModifier(label: "Due Date"))

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
                SplitMarkdownEdit(label: "Description", text: $reminder.unwrappedNotes)
                    .frame(minHeight: 500, maxHeight: .infinity)
            }
        }
    }
}

struct EKReminderEditView_Previews: PreviewProvider {
    static var previews: some View {
        EKReminderEditView(reminder: .constant(.init()))
    }
}
