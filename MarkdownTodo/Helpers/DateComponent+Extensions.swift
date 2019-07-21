//
//  DateComponent+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

extension DateComponents {
    static func setToday() -> DateComponents {
        let newDate = Date()
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: newDate)
    }

    static func setDue(to newDate: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: newDate)
    }
}
