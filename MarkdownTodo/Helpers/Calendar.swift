//
//  Calendar.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import EventKit

struct ReminderGroupDate: ReminderGroup {
    var title: String {
        get {
            return date == Date.distantFuture ? Labels.unscheduled : Formats.full(date)
        }
    }
    let date: Date
    let events: [EKReminder]
}

struct ReminderGroupPriority: ReminderGroup {
    var title: String {
        get {
            return "Priority: \(priority)"
        }
    }
    let priority: Int
    let events: [EKReminder]
}

final class ReminderManager {
    enum Group { case date, priority }
    enum SortableField { case date, priority, creation }

    static func reminders(_ reminders: [EKReminder], byGrouping: Group, orderedBy: SortableField) -> [ReminderGroup] {

        var sortable: (EKReminder, EKReminder) -> Bool
        switch orderedBy {
        case .priority:
            sortable = { $0.priority < $1.priority }
        case .date:
            sortable = { $0.sortableDate < $1.sortableDate }
        case .creation:
            sortable = { $0.creationDate! < $1.creationDate! }
        }

        switch byGrouping {
        case .date:
            let grouped = Dictionary(grouping: reminders) { (reminder) -> Date in
                reminder.sortableDate
            }
            let mapped = grouped.map { (date, list) -> ReminderGroupDate in
                return ReminderGroupDate(date: date, events: list.sorted(by: sortable)  )
            }
            return mapped.sorted {$0.date < $1.date }
        case .priority:
            let grouped = Dictionary(grouping: reminders) { (reminder) -> Int in
                reminder.priority
            }
            let mapped = grouped.map { (priority, list) -> ReminderGroupPriority in
                return ReminderGroupPriority(priority: priority, events: list.sorted(by: sortable))
            }
            return mapped.sorted { $0.priority < $1.priority }
        }
    }

    static func titleFromDate(_ reminder: EKReminder) -> String {
        if reminder.isCompleted {
            return Formats.full(reminder.completionDate!)
        }

        if let comp = reminder.dueDateComponents {
            return Formats.full(comp.date!)
        }

        return Labels.unscheduled
    }
}

struct CalendarGroup {
    let title: String
    let list: [EKCalendar]
}

extension CalendarGroup {
    static func fetch() -> [CalendarGroup] {
        return CalendarAPI.shared.filteredSources().map { (source) -> CalendarGroup in
            let calendars = source.calendars(for: .reminder).sorted { $0.cgColor.hashValue > $1.cgColor.hashValue }
            return CalendarGroup(title: source.title, list: calendars)
            }.sorted { $0.title < $1.title }
    }
}
