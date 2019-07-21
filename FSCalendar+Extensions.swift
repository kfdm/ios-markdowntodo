//
//  FCCalendar+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import FSCalendar

extension FSCalendar {
    func clearAllSelections() {
        selectedDates.forEach { (date) in
            deselect(date)
        }
    }
}
