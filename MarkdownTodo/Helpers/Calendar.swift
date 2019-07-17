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

class GroupedReminders {
    var reminders: [Date: [EKReminder]]
    var sections: [Date]

    var numberOfSections: Int { get { return self.sections.count }}

    init () {
        self.reminders = [Date: [EKReminder]]()
        self.sections = [Date]()
    }

    init(reminders: [EKReminder]) {
        self.reminders = Dictionary.init(grouping: reminders) {
            if let completed = $0.completionDate { return completed }
            if let due = $0.dueDateComponents?.date { return due}
            return Date.distantFuture
        }
        self.sections = self.reminders.keys.sorted()
    }

    func section(_ for_: Int) -> Date {
        return self.sections[for_]
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        let date = self.sections[section]
        return self.reminders[date]!.count
    }

    func reminderForRowAt(_ indexPath: IndexPath) -> EKReminder {
        let date = self.sections[indexPath.section]
        return reminders[date]![indexPath.row]
    }
}

class CalendarController {
    static let shared = CalendarController()

    let store = EKEventStore.init()
    var calendars = [EKSource: [EKCalendar]]()
    var sources = [EKSource]()

    func source(for section: Int) -> [EKCalendar] {
        let source = sources[section]
        return calendars[source]!
    }

    func calendar(for indexPath: IndexPath) -> EKCalendar {
        let source = sources[indexPath.section]
        return calendars[source]![indexPath.row]
    }

    func setup() {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            os_log("Authorized", log: logger, type: .info)
            refreshData()
        case .denied:
            os_log("Denied", log: logger, type: .error)
        case .notDetermined:
            store.requestAccess(to: .reminder) { (granted, _) in
                if granted {
                    os_log("Granted", log: logger, type: .info)
                    self.refreshData()
                } else {
                    os_log("Denied", log: logger, type: .error)
                }
            }
        case.restricted:
            print("Restricted")
        default:
            print("Unknown case")
        }
    }

    func predicateForReminders(in calendar: EKCalendar, completionHandler: @escaping (_ result: [EKReminder]) -> Void) {
        let pred = store.predicateForReminders(in: [calendar])
        store.fetchReminders(matching: pred) { (fetchedReminders) in
            if let newReminders = fetchedReminders {
                completionHandler(newReminders)
            }
        }
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
