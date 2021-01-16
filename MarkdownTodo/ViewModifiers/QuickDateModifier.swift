//
//  QuickDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/10.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct CalendarDatePicker: View {
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
            .frame(
                minWidth: 30, idealWidth: 40, maxWidth: 40,
                minHeight: 30, idealHeight: 40, maxHeight: 40
            )
            .modifier(DateHighlightModifier(selectedDate: $selectedDate, date: date))
            .clipShape(Circle())
        }
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
