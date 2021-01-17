//
//  ReminderRow.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct PriorityStripe: View {
    let priority: Int
    var color: Color {
        switch priority {
        case 1...2:
            return Color.red
        case 3...4:
            return Color.orange
        case 5...6:
            return Color.green
        case 7...9:
            return Color.blue
        default:
            return Color.gray
        }
    }
    var body: some View {
        color.frame(width: 8)
    }
}

struct CompletedCheckbox: View {
    @EnvironmentObject var eventStore: EventStore
    @Binding var reminder: EKReminder

    var body: some View {
        Group {
            if reminder.isCompleted {
                Image(systemName: "checkmark.square")
            } else {
                Image(systemName: "square")
            }
        }.onTapGesture(perform: actionClickCheckbox)
    }

    func actionClickCheckbox() {
        eventStore.toggleComplete(reminder)
    }
}

struct ReminderRow: View {
    @State var reminder: EKReminder
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        HStack {
            PriorityStripe(priority: reminder.priority)
            CompletedCheckbox(reminder: $reminder)
                .font(.title)
            VStack(alignment: .leading) {
                Text(reminder.title)
                Text(reminder.calendar.title)
                    .foregroundColor(reminder.calendar.color)
            }
            Spacer()
            if let completionDate = reminder.completionDate {
                DateView(date: completionDate)
                    .foregroundColor(.gray)
            } else {
                QuickDatePicker(label: "Due Date", date: $reminder.dueDateComponents) {
                    eventStore.save(reminder)
                }
                .modifier(HighlightOverdue(date: reminder.dueDateComponents))
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
