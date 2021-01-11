//
//  CalendarPicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/09.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

private struct CalendarPickerSheet: View {
    @EnvironmentObject var store: EventStore
    @Binding var current: EKCalendar
    var action: (EKCalendar) -> Void

    var body: some View {
        List {
            ForEach(store.sources) { (source) in
                Section(header: Text(source.title)) {
                    ForEach(store.calendars(for: source)) { calendar in
                        Button(calendar.title, action: { action(calendar) })
                            .foregroundColor(calendar.color)
                            .listRowBackground(
                                current.calendarIdentifier == calendar.calendarIdentifier
                                    ? Color.accentColor.opacity(0.2) : Color.clear)
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct EKCalendarPicker: View {
    @Binding var calendar: EKCalendar
    @State private var isPresented = false

    var body: some View {
        Button(calendar.title, action: actionToggleSheet)
            .foregroundColor(calendar.color)
            .modifier(LabelModifier(label: "Calendar"))
            .sheet(isPresented: $isPresented) {
                NavigationView {
                    CalendarPickerSheet(current: $calendar, action: actionSelected)
                }
                .navigationTitle("Select Calendar")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", action: actionToggleSheet)
                    }
                }
            }
    }

    private func actionToggleSheet() {
        isPresented.toggle()
    }

    private func actionSelected(_ selectedCalendar: EKCalendar) {
        isPresented.toggle()
        calendar = selectedCalendar
    }
}

struct CalendarPicker_Previews: PreviewProvider {
    static var previews: some View {
        EKCalendarPicker(calendar: .constant(EKCalendar()))
    }
}
