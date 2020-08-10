//
//  QuickDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/10.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct QuickDateModifier: ViewModifier {
    @Binding public var date: DateComponents?
    @Binding public var reminder: EKReminder

    @State private var showPicker = false
    @State private var selectedDate = Date()
    @Environment(\.calendar) var calendar
    @EnvironmentObject var eventStore: EventStore

    func body(content: Content) -> some View {
        return
            content
            .onTapGesture(perform: performTapGesture)
            .sheet(isPresented: $showPicker) {
                NavigationView {
                    List {
                        Section(header: Text("Quick Select")) {
                            Button("Today", action: { updateAndSave(date: Date()) })
                            Button("Tomorrow", action: { updateAndSave(date: Date().tomorrow) })
                            Button(
                                "Next Weekend",
                                action: { updateAndSave(date: Date().nextDate(dayOfTheWeek: 7)) })
                            Button(
                                "Next Week",
                                action: { updateAndSave(date: Date().nextDate(dayOfTheWeek: 2)) })
                            Button("Unset", action: { updateAndSave(date: nil) })
                        }
                        DatePicker("Date", selection: $selectedDate)
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("Date Picker", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Cancel", action: actionCancel),
                        trailing: Button("Save", action: { updateAndSave(date: selectedDate) })
                    )
                }.navigationViewStyle(StackNavigationViewStyle())
            }
    }

    func performTapGesture() {
        showPicker = true
        selectedDate = date?.date ?? Date()
    }

    func actionCancel() {
        reminder.reset()
        showPicker = false
    }

    func updateAndSave(date newDate: Date?) {
        date = calendar.dateComponents(from: newDate)
        try? eventStore.save(reminder)
        showPicker = false
    }
}

extension Calendar {
    func dateComponents(from date: Date?) -> DateComponents? {
        if let date = date {
            return dateComponents([.year, .month, .day, .hour, .minute], from: date)
        }
        return nil
    }
}
