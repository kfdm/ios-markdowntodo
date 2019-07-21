//
//  EKReminder+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

enum ReminderState {
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

    var scheduledState: ReminderState {
        get {
            if isCompleted { return .completed}
            guard let dueDate = dueDateComponents?.date else { return .unscheduled }
            let today = Date()
            return dueDate > today ? .scheduled : .overdue
        }
    }
}
