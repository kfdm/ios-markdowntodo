//
//  CalendarDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct DateBorderModifier: ViewModifier {
    @Binding var reminders: [EKReminder]
    var date: Date

    var count: Int {
        return reminders.filter(date: date).count
    }

    var width: CGFloat {
        CGFloat(min(4, count))
    }

    func body(content: Content) -> some View {
        return
            content
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: width)
            )
    }
}

struct DateHighlightModifier: ViewModifier {
    @Environment(\.calendar) var calendar
    @Binding var selectedDate: Date

    let date: Date

    func body(content: Content) -> some View {
        // Current selected date
        if calendar.isDate(date, equalTo: selectedDate, toGranularity: .day) {
            return content.background(Circle().fill(Color.red.opacity(0.2)))
        }

        // Current date
        if calendar.isDateInToday(date) {
            return content.background(Circle().fill(Color.accentColor.opacity(0.2)))
        }

        // All other dates
        return content.background(Circle().fill(Color.secondary.opacity(0.1)))
    }
}

struct HighlightOverdue: ViewModifier {
    let date: Date
    let today = Date()

    func body(content: Content) -> some View {
        if date.endOfDay < today.endOfDay {
            return content.foregroundColor(.red)
        }
        return content.foregroundColor(nil)
    }

    init(date: DateComponents?) {
        self.date = date?.date ?? Date()
    }
}
