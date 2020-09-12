//
//  CalendarDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct DateIndicator: View {
    var reminders: [EKReminder]
    var body: some View {
        Group {
            switch reminders.count {
            case 0:
                Text(" ")
            case 1...3:
                Text(String(repeating: ".", count: reminders.count))
            default:
                Text("....")
            }
        }
        .font(.caption)
    }
}

struct CalendarDateAttachments: ViewModifier {
    @Binding var reminders: [Date: [EKReminder]]
    var date: Date

    func body(content: Content) -> some View {
        return VStack {
            content
            DateIndicator(reminders: reminders[date] ?? [])
        }
    }
}

struct CalendarDateModifier: ViewModifier {
    @Environment(\.calendar) var calendar
    @Binding var selectedDate: Date

    let date: Date

    func body(content: Content) -> some View {
        if calendar.isDate(date, equalTo: selectedDate, toGranularity: .day) {
            return content.background(Color.red.opacity(0.2))
        }

        if calendar.isDateInToday(date) {
            return content.background(Color.blue.opacity(0.2))
        }

        return content.background(Color.gray.opacity(0.1))
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
