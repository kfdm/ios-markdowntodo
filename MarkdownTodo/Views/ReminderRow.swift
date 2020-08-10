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
        Rectangle()
            .stroke(color, lineWidth: 4)
            .frame(width: 4)
    }
}

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
        try? eventStore.toggleComplete(reminder)
    }

    var body: some View {
        HStack {
            PriorityStripe(priority: reminder.priority)
            checkmark.font(.title)
            VStack(alignment: .leading) {
                Text(reminder.title)
                Text(reminder.calendar.title)
                    .foregroundColor(reminder.calendar.color)
            }
            Spacer()
            DateView(date: reminder.dueDateComponents, whenUnset: "No Due Date")
                .modifier(HighlightOverdue(date: reminder.dueDateComponents))
                .modifier(QuickDateModifier(date: $reminder.dueDateComponents, reminder: $reminder))
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
