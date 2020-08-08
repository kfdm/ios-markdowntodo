//
//  ReminderRow.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct ReminderRow: View {
    @EnvironmentObject var eventStore: EventStore

    @State var reminder: EKReminder

    var checkmark: some View {
        Group {
            if reminder.isCompleted {
                Image(systemName: "checkmark.square")
            } else {
                Image(systemName: "square")
            }
        }.onTapGesture(perform: actionClickCheckbox)
    }

    func actionClickCheckbox() {
        reminder = eventStore.toggleComplete(reminder)
    }

    var body: some View {
        HStack {
            checkmark.font(.title)
            VStack(alignment: .leading) {
                Text(reminder.title)
                Text(reminder.calendar.title)
                    .foregroundColor(reminder.calendar.color)
            }
            Spacer()
            if let dueDate = reminder.dueDateComponents {
                DateView(date: dueDate).modifier(HighlightOverdue(date: dueDate.date!))
            }
            if reminder.hasURL {
                Image(systemName: "link")
            }
            if reminder.hasRecurrenceRules {
                Image(systemName: "clock")
            }
        }
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        ReminderRow(reminder: EKReminder())
    }
}
