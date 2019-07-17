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

class GroupedRemindersByDate: GroupedReminders {
    private var reminders = [Date: [EKReminder]]()
    private var sections = [Date]()

    var numberOfSections: Int { get { return self.sections.count }}

    init() {

    }

    func titleForHeader(_ section: Int) -> String {
        let date = sections[section]
        if date == Date.distantFuture { return "Unscheduled" }

        let format = DateFormatter()
        format.locale = .current
        format.dateStyle = .full
        return format.string(from: date)
    }

    init(reminders: [EKReminder]) {
        self.reminders = Dictionary.init(grouping: reminders) {
            if let completed = $0.completionDate { return completed }
            if let due = $0.dueDateComponents?.date { return due}
            return Date.distantFuture
        }
        self.sections = self.reminders.keys.sorted()
    }

    static func remindersForPredicate(predicate: NSPredicate, showCompleted: Bool, completionHandler: @escaping (GroupedRemindersByDate) -> Void) {
        CalendarManager.shared.store.fetchReminders(matching: predicate) { (reminders) in
            guard let reminders = reminders else { return }
            if showCompleted {
                completionHandler(GroupedRemindersByDate(reminders: reminders))
            } else {
                completionHandler(GroupedRemindersByDate(reminders: reminders.filter({ (r) -> Bool in
                    !r.isCompleted
                })))
            }
        }
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        let date = sections[section]
        guard let source = reminders[date] else { return 0}
        return source.count
    }

    func reminderForRowAt(_ indexPath: IndexPath) -> EKReminder {
        let date = self.sections[indexPath.section]
        return reminders[date]![indexPath.row]
    }
}

class GroupedCalendarBySource {
    private var sources: [EKSource]?
    private var calendars: [EKSource: [EKCalendar]]?
    private var store = CalendarManager.shared.store

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
        store.refreshSourcesIfNecessary()

        sources = store.sources.filter({ (source) -> Bool in
            source.sourceType == .calDAV
        }).sorted(by: { (a, b) -> Bool in
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
