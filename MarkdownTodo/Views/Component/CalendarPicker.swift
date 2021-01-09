//
//  CalendarPicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/09.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import SwiftUI
import EventKit

struct CalendarPicker: View {
    @Binding var calendar: EKCalendar

    var body: some View {
        Text(calendar.title)
            .foregroundColor(calendar.color)
    }
}

struct CalendarPicker_Previews: PreviewProvider {
    static var previews: some View {
        CalendarPicker(calendar: .constant(EKCalendar()))
    }
}
