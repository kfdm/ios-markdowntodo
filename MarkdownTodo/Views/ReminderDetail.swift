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
    @State var test = Date()

    var body: some View {
        HStack {

            if date != nil {
                //                DateView(date: date!)
                DatePicker(selection: $test, displayedComponents: .date) {
                    Text(label)
                }
            } else {
                Text(label)
                Spacer()
                Text("Unscheduled")
            }
        }
    }
}

struct ReminderDetail: View {
    @EnvironmentObject var store: EventStore
    @State var reminder: EKReminder
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(header: EmptyView()) {
                NameField(label: "Title", value: $reminder.title)
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
        .navigationBarItems(
            leading: Button("Cancel", action: cancelAction),
            trailing: Button("Save", action: saveAction)
        )
        .navigationBarTitle(reminder.title)
        .navigationBarBackButtonHidden(true)
    }

    func saveAction() {
        try? store.save(reminder)
        presentationMode.wrappedValue.dismiss()
    }

    func cancelAction() {
        reminder.reset()
        presentationMode.wrappedValue.dismiss()
    }
}

struct ReminderDetail_Previews: PreviewProvider {
    static var store = EventStore()
    static var previews: some View {
        ReminderDetail(reminder: EKReminder())
            .environmentObject(store)
    }
}
