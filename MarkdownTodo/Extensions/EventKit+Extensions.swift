//
//  EventKit+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit

extension EKEventStore {
    func remove(_ reminders: [EKReminder], commit: Bool) throws {
        try reminders.forEach { reminder in
            try remove(reminder, commit: false)
        }
        if commit {
            try self.commit()
        }
    }
    func save(_ reminders: [EKReminder], commit: Bool) throws {
        try reminders.forEach { reminder in
            try save(reminder, commit: false)
        }
        if commit {
            try self.commit()
        }
    }
}

extension EKReminder {
    var hasURL: Bool {
        return url != nil
    }

    var dueDate: Date {
        return dueDateComponents?.date ?? Date.distantFuture
    }

    var unwrappedNotes: String {
        get { return notes ?? "" }
        set { notes = newValue }
    }
}

extension Array where Element == EKReminder {
    func byDueDate() -> [Date: [EKReminder]] {
        return Dictionary(
            grouping: self,
            by: { Calendar.current.startOfDay(for: $0.dueDate) }
        )
    }
    func byCreateDate() -> [Date: [EKReminder]] {
        return Dictionary(
            grouping: self,
            by: { Calendar.current.startOfDay(for: $0.creationDate ?? Date.distantFuture) }
        )
    }
    func byPriority() -> [Int: [EKReminder]] {
        return Dictionary(
            grouping: self,
            by: { $0.priority }
        )
    }
    func byCalendar() -> [EKCalendar: [EKReminder]] {
        return Dictionary(
            grouping: self,
            by: { $0.calendar }
        )
    }
    func byAgenda() -> [Date: [EKReminder]] {
        let today = Calendar.current.startOfDay(for: Date())

        return Dictionary(
            grouping: self,
            by: {
                if $0.dueDate < today {
                    return Date.distantPast
                }
                return Calendar.current.startOfDay(for: $0.dueDate)
            }
        )
    }

    /// Filter tasks due on this date
    /// - Parameter date: Will check startOfDay and endOfDay for this date
    /// - Returns: All EKReminders due on this date
    func dueOn(date: Date) -> [EKReminder] {
        return self.filter {
            return $0.dueDate > date.startOfDay && $0.dueDate < date.endOfDay
        }
    }
}
