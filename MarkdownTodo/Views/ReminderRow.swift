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
    var reminder: EKReminder

    var checkmark: some View {
        if reminder.isCompleted {
            return Image(systemName: "checkmark:square")
        } else {
            return Image(systemName: "square")
        }
    }

    var body: some View {
        HStack {
            checkmark
            VStack(alignment: .leading) {
                Text(reminder.title)
                Text(reminder.calendar.title)
                    .foregroundColor(reminder.calendar.color)
            }
            if reminder.dueDateComponents != nil {
                Spacer()
                DateView(date: reminder.dueDateComponents!)
            }
        }
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        ReminderRow(reminder: EKReminder())
    }
}
