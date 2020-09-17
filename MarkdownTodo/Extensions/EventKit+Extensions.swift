//
//  EventKit+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit

extension EKReminder {
    var hasURL: Bool {
        return url != nil
    }

    var hasDueDate: Bool {
        return dueDateComponents != nil
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
                if Calendar.current.startOfDay(for: $0.dueDate) == today {
                    return today
                }

                if $0.dueDate < today {
                    return Date.distantPast
                }
                return Date.distantFuture
            }
        )
    }

    func filter(date: Date) -> [EKReminder] {
        return self.filter { $0.dueDate.startOfDay == date.startOfDay }
    }
}
