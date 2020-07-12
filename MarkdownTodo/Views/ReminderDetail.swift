//
//  ReminderDetail.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct ReminderDetail: View {
    var reminder: EKReminder

    var body: some View {
        List {
            NameValue(label: "Title", value: reminder.title)
            NameValue(label: "Calendar", value: reminder.calendar.title)
            if reminder.dueDateComponents != nil {
                DateLabel(label: "Due Date", date: reminder.dueDateComponents!)
            }
            if reminder.url != nil {
                Link(label: reminder.url!.absoluteString, destination: reminder.url!)
            }
        }
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetail(reminder: EKReminder())
    }
}
