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

    let date: Date

    func body(content: Content) -> some View {
        if calendar.isDateInToday(date) {
            return content.background(Color.blue.opacity(0.2))
        } else {
            return content.background(Color.gray.opacity(0.1))
        }
    }

}
