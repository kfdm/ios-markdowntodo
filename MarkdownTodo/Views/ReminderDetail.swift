//
//  ReminderDetail.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct NameValue: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}

struct DateView: View {
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    var date: Date
    var body: some View {
        Text(formatter.string(from: date))
    }
}

struct DateLabel: View {
    var label: String
    var date: Date

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            DateView(date: date)
        }
    }
}

extension DateLabel {
    init(label: String, date: DateComponents) {
        self.label = label
        self.date = date.date!
    }
}

extension DateView {
    init(date from: DateComponents) {
        date = from.date!
    }
}

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
                NameValue(label: "URL", value: reminder.url!.absoluteString)
            }
        }
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetail(reminder: EKReminder())
    }
}
