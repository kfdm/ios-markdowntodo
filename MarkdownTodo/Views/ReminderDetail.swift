//
//  ReminderDetail.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct DateSelector: View {
    var label: String
    var date: DateComponents?

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            if date != nil {
                DateView(date: date!)
            } else {
                Text("Unscheduled")
            }
        }
    }
}

struct ReminderDetail: View {
    @State var reminder: EKReminder

    var body: some View {
        List {
            Section(header: EmptyView()) {
                NameValue(label: "Title", value: reminder.title)
                NameValue(label: "Calendar", value: reminder.calendar.title)
                Picker("Priority", selection: $reminder.priority) {
                    ForEach(0..<10) { p in
                        Text("\(p)").tag(p)
                    }
                }.pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Date")) {
                DateSelector(label: "Start Date", date: reminder.startDateComponents)
                DateSelector(label: "Due Date", date: reminder.dueDateComponents)
            }
            Section(header: Text("Other")) {
                if reminder.url != nil {
                    Link(label: reminder.url!.absoluteString, destination: reminder.url!)
                }
                MarkdownView(label: "Description", text: $reminder.notes)
            }
        }
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetail(reminder: EKReminder())
    }
}
