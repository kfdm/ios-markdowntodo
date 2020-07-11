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
            VStack {
                Text(reminder.title)
                Text(reminder.dueDateComponents.debugDescription)
            }
        }
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        ReminderRow(reminder: EKReminder())
    }
}
