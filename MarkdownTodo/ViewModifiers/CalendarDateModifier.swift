//
//  CalendarDateModifier.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

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

    func body(content: Content) -> some View {
        if date < Date().midnight {
            return content.foregroundColor(.red)
        }
        return content.foregroundColor(nil)
    }
}
