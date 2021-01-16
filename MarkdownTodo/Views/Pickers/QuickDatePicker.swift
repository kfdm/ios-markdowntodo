//
//  QuickDatePicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.calendar) var calendar
    @State private var selectedDate = Date()

    var action: (Date?) -> Void

    var body: some View {
        List {
            Section(header: Text("Quick Select")) {
                Button("Today", action: selectToday)
                Button("Tomorrow", action: selectTomorrow)
                Button("Next Weekend", action: selectWeekend)
                Button("Next Week", action: selectNextWeek)
            }
            CalendarDatePicker(selectedDate: $selectedDate, action: action)
        }
        .listStyle(GroupedListStyle())
    }

    func selectToday() {
        let selection = calendar.endOfDay(for: .init())
        action(selection)
    }

    func selectTomorrow() {
        let selection = calendar.endOfDay(for: .init()).tomorrow
        action(selection)
    }
    func selectWeekend() {
        let today = calendar.endOfDay(for: .init())
        let selection = today.nextDate(dayOfTheWeek: 7)
        action(selection)
    }
    func selectNextWeek() {
        let today = calendar.endOfDay(for: .init())
        let selection = today.nextDate(dayOfTheWeek: 2)
        action(selection)
    }
}

struct QuickDatePicker: View {
    var label: String
    @Binding var date: DateComponents?
    var hook: () -> Void = {}

    @State private var isPresented = false
    @Environment(\.calendar) var calendar
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        Button(action: actionShow) {
            if let current = date?.date {
                DateView(date: current)
            } else {
                Text("No \(label)")
            }
        }
        .onTapGesture(perform: actionShow)
        .sheet(isPresented: $isPresented) {
            NavigationView {
                DatePickerSheet(action: selectDate)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: actionShow)
                        }
                    }
                    .navigationTitle("Select \(label)")
            }
        }
    }

    private func actionShow() {
        isPresented.toggle()
    }

    private func selectDate(date: Date?) {
        isPresented.toggle()
        self.date = calendar.dateComponents(from: date)
        eventStore.objectWillChange.send()
        hook()
    }
}
//
//struct QuickDatePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickDatePicker()
//    }
//}
