//
//  EKReminder+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

enum ScheduledOptions {
    case completed
    case scheduled
    case overdue
    case unscheduled
}

extension EKReminder {
    var sortableDate: Date {
        if isCompleted { return completionDate! }
        if let dueDate = dueDateComponents?.date { return dueDate}
        return Date.distantFuture
    }

    var scheduledState: ScheduledOptions {
        get {
            if isCompleted { return .completed}
            return sortableDate > Date() ? .scheduled : .overdue
        }
    }

    func setDueToday() {
        let newDate = Date()
        let calendar = Calendar.current
        dueDateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
    }

    func setDue(to newDate: Date) {
        let calendar = Calendar.current
        dueDateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
    }
}
