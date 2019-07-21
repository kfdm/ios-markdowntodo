//
//  Calendar.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import EventKit
import os.log

let logger = OSLog(subsystem: "com.myapp.xx", category: "UI")

final class ReminderManager {
    enum Group { case date, priority }
    enum SortableField { case date, priority }

    struct ReminderGroup {
        let title: String
        let events: [EKReminder]
    }

    static func reminders(_ reminders: [EKReminder], byGrouping: Group, orderedBy: SortableField) -> [ReminderGroup] {
        switch byGrouping {
        case .date:
            let grouped = Dictionary(grouping: reminders.sorted(by: { $0.sortableDate < $1.sortableDate })) { (reminder) -> Date in
                reminder.sortableDate
            }
            let mapped = grouped.map { (date, list) -> ReminderGroup in
                let format = DateFormatter()
                format.locale = .current
                format.dateStyle = .full
                let title = date == Date.distantFuture ? "Unscheduled" : format.string(from: date)

                switch(orderedBy) {
                case .date:
                    return ReminderGroup(title: title, events: list.sorted { $0.sortableDate > $1.sortableDate })
                case .priority:
                    return ReminderGroup(title: title, events: list.sorted { $0.priority < $1.priority })
                }

            }
            return mapped.sorted { $0.title < $1.title }
        case .priority:
            return [ReminderGroup]()
        }
    }

    static func titleFromDate(_ reminder: EKReminder) -> String {
        let format = DateFormatter()
        format.locale = .current
        format.dateStyle = .full

        if reminder.isCompleted {
            return format.string(from: reminder.completionDate!)
        }

        if let comp = reminder.dueDateComponents {
            return format.string(from: comp.date!)
        }

        return "Unscheduled"
    }
}

class GroupedCalendarBySource {
    private var sources: [EKSource]?
    private var calendars: [EKSource: [EKCalendar]]?

    var numberOfSections: Int { get { return sources?.count ?? 0 } }

    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = sources?[section] else { return 0 }
        guard let source = calendars?[section] else { return 0 }
        return source.count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> EKCalendar {
        let section = sources![indexPath.section]
        return calendars![section]![indexPath.row]
    }

    func titleForHeader(_ section: Int) -> String {
        return sources![section].title
    }

    init() {
        sources = CalendarManager.shared.filteredSources()

        sources = CalendarManager.shared.filteredSources().sorted(by: { (a, b) -> Bool in
            a.title < b.title
        })

        calendars = [EKSource: [EKCalendar]]()

        sources?.forEach { (source) in
            calendars?[source] = source.calendars(for: .reminder).sorted(by: { (a, b) -> Bool in
                a.cgColor.hashValue > b.cgColor.hashValue
            })
        }
    }
}
