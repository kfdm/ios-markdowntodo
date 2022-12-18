//
//  CalendarDatePicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import SwiftUI

struct CalendarDatePicker: View {
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }

    @Environment(\.calendar) var calendar
    @Binding var selectedDate: Date
    var action: (Date) -> Void

    var body: some View {
        MecidCalendarView(interval: month) { date in
            Button(String(self.calendar.component(.day, from: date))) {
                action(date)
            }
            .frame(
                minWidth: 30, idealWidth: 40, maxWidth: 40,
                minHeight: 30, idealHeight: 40, maxHeight: 40
            )
            .modifier(DateHighlightModifier(selectedDate: $selectedDate, date: date))
            .clipShape(Circle())
        }
    }
}

struct CalendarDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDatePicker(selectedDate: .constant(Date())) { date in
            print(date.debugDescription)
        }
    }
}
