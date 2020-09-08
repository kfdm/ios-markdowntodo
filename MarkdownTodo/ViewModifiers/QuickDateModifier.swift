//
//  QuickDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/10.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct CalendarPicker: View {
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }

    @Environment(\.calendar) var calendar
    @Binding var selectedDate: Date
    var action: (Date) -> Void

    var body: some View {
        CalendarView(interval: month) { date in
            Button(String(self.calendar.component(.day, from: date))) {
                action(date)
            }
            .frame(width: 40, height: 40, alignment: .center)
            .modifier(CalendarDateModifier(selectedDate: $selectedDate, date: date))
            .clipShape(Circle())
        }
    }
}

struct QuickDateModifier: ViewModifier {
    var navigationBarTitle: String
    @Binding public var date: DateComponents?
    @Binding public var reminder: EKReminder

    @State private var showPicker = false
    @State private var selectedDate = Date()
    @Environment(\.calendar) var calendar
    @EnvironmentObject var eventStore: EventStore

    var sheet: some View {
        List {
            Section(header: Text("Quick Select")) {
                let today = calendar.startOfDay(for: Date())
                Button(
                    "Today",
                    action: { updateAndSave(date: calendar.endOfDay(for: today)) })
                Button(
                    "Tomorrow",
                    action: {
                        updateAndSave(date: calendar.endOfDay(for: today.tomorrow))
                    })
                Button(
                    "Next Weekend",
                    action: { updateAndSave(date: today.nextDate(dayOfTheWeek: 7)) })
                Button(
                    "Next Week",
                    action: { updateAndSave(date: today.nextDate(dayOfTheWeek: 2)) })
                Button("Unset", action: { updateAndSave(date: nil) })
            }
            CalendarPicker(selectedDate: $selectedDate) { date in
                updateAndSave(date: date)
            }
        }.listStyle(GroupedListStyle())
    }

    func body(content: Content) -> some View {
        return
            content
            .onTapGesture(perform: performTapGesture)
            .sheet(isPresented: $showPicker) {
                NavigationView {
                    sheet
                        .navigationBarTitle(Text(navigationBarTitle), displayMode: .inline)
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
