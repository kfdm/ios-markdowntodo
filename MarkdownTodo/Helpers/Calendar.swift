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

class GroupedRemindersByDate {
    private var reminders = [Date: [EKReminder]]()
    private var sections = [Date]()

    var numberOfSections: Int { get { return self.sections.count }}

    init() {

    }

    init(reminders: [EKReminder]) {
        self.reminders = Dictionary.init(grouping: reminders) {
            if let completed = $0.completionDate { return completed }
            if let due = $0.dueDateComponents?.date { return due}
            return Date.distantFuture
        }
        self.sections = self.reminders.keys.sorted()
    }

    static func remindersForPredicate(predicate: NSPredicate, completionHandler: @escaping (GroupedRemindersByDate) -> Void) {
        CalendarController.shared.store.fetchReminders(matching: predicate) { (reminders) in
            guard let reminders = reminders else { return }
            completionHandler(GroupedRemindersByDate(reminders: reminders))
        }
    }

    func section(_ for_: Int) -> Date {
        return self.sections[for_]
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
    private var store = CalendarController.shared.store

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

class CalendarController {
    static let shared = CalendarController()

    var isAuthenticated = false

    let store = EKEventStore.init()
    private var calendars = [EKSource: [EKCalendar]]()
    private var sources = [EKSource]()

    func source(for section: Int) -> [EKCalendar] {
        let source = sources[section]
        return calendars[source]!
    }

    func calendar(for indexPath: IndexPath) -> EKCalendar {
        let source = sources[indexPath.section]
        return calendars[source]![indexPath.row]
    }

    func authenticated(completionHandler handler: @escaping () -> Void) {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            os_log("Authorized", log: logger, type: .info)
            isAuthenticated = true
            handler()
        case .denied:
            os_log("Denied", log: logger, type: .error)
        case .notDetermined:
            store.requestAccess(to: .reminder) { (granted, _) in
                if granted {
                    os_log("Granted", log: logger, type: .info)
                    self.isAuthenticated = true
                    handler()
                } else {
                    os_log("Access Denied", log: logger, type: .error)
                }
            }
        case.restricted:
            os_log("Restricted", log: logger, type: .error)
        default:
            os_log("Unknown Case", log: logger, type: .error)
        }
    }

    func fetchReminders(matching predicate: NSPredicate, completionHandler: @escaping (_ result: [EKReminder]) -> Void) {
        store.fetchReminders(matching: predicate) { (fetchedReminders) in
            if let newReminders = fetchedReminders {
                completionHandler(newReminders)
            }
        }
    }

    func remindersForToday(completionHandler handler: @escaping (_ result: [EKReminder]) -> Void) {
        let pred = store.predicateForEvents(withStart: Date(), end: Date(), calendars: nil)
        fetchReminders(matching: pred, completionHandler: handler)
    }

    func remindersForCompleted(_ calendar: EKCalendar, completionHandler handler: @escaping (_ result: [EKReminder]) -> Void) {
        let pred = store.predicateForCompletedReminders(withCompletionDateStarting: nil, ending: nil, calendars: [calendar])
        fetchReminders(matching: pred, completionHandler: handler)
    }

    func predicateForReminders(in calendar: EKCalendar) -> NSPredicate {
        return store.predicateForReminders(in: [calendar])
    }

    func fetchCalendarList() -> [EKSource: [EKCalendar]] {
        store.refreshSourcesIfNecessary()
        var calendars = [EKSource: [EKCalendar]]()

        store.sources.filter({ (source) -> Bool in
            source.sourceType != .birthdays
        }).forEach { (source) in
            calendars[source] = source.calendars(for: .reminder).sorted(by: { (a, b) -> Bool in
                a.cgColor.hashValue > b.cgColor.hashValue
            })
        }
        return calendars
    }

    func refreshData() {
        store.refreshSourcesIfNecessary()
        sources = store.sources.filter({ (source) -> Bool in
            source.sourceType != .birthdays
        })

        sources.forEach { (source) in
            calendars[source] = source.calendars(for: .reminder).sorted(by: { (a, b) -> Bool in
                a.cgColor.hashValue > b.cgColor.hashValue
            })
        }
    }

    func save(reminder: EKReminder, commit: Bool) {
        do {
            try store.save(reminder, commit: commit)
        } catch {
            print("Error creating and saving new reminder : \(error)")
        }
    }

    func newReminder(for calendar: EKCalendar) -> EKReminder {
        let calendar = store.calendar(withIdentifier: calendar.calendarIdentifier)
        let reminder = EKReminder.init(eventStore: store)
        reminder.calendar = calendar
        return reminder
    }
}
