//
//  CalendarManager.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/18.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import EventKit

import os.log

class CalendarManager {
    static let shared = CalendarManager()

    var isAuthenticated = false

    private let store = EKEventStore.init()
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "CalendarManager", category: "CalendarManager")
    private var eventCount = [Date: Int]()

    func authenticated(completionHandler handler: @escaping () -> Void) {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            os_log("Authorized", log: logger, type: .info)
            isAuthenticated = true
            NotificationCenter.default.post(name: .authenticationGranted, object: nil)
        case .denied:
            os_log("Denied", log: logger, type: .error)
        case .notDetermined:
            store.requestAccess(to: .reminder) { (granted, _) in
                if granted {
                    os_log("Granted", log: self.logger, type: .info)
                    self.isAuthenticated = true
                    NotificationCenter.default.post(name: .authenticationGranted, object: nil)
                } else {
                    os_log("Access Denied", log: self.logger, type: .error)
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

    func save(reminder: EKReminder, commit: Bool) {
        os_log("Saving updates to reminder: %@", log: logger, type: .error, reminder)
        do {
            try store.save(reminder, commit: commit)
            NotificationCenter.default.post(name: .savedReminder, object: reminder)
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

    func predicateForIncompleteReminders(withDueDateStarting start: Date, ending: Date, calendars: [EKCalendar]?) -> NSPredicate {
        return store.predicateForIncompleteReminders(withDueDateStarting: start, ending: ending, calendars: calendars)
    }

    func remove(_ reminder: EKReminder, commit: Bool) {
        try? store.remove(reminder, commit: commit)
    }

    func refreshSourcesIfNecessary() {
        store.refreshSourcesIfNecessary()
    }

    func filteredSources() -> [EKSource] {
        store.refreshSourcesIfNecessary()
        return store.sources.filter({ (source) -> Bool in
            source.sourceType == .calDAV
        })
    }

    func numberOfEventsFor(_ date: Date) -> Int {
        return eventCount[date.midnight] ?? 0
    }

    func recalculateEventCount(_ completionHandler: @escaping () -> Void) {
        let pred = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        store.fetchReminders(matching: pred) { (fetchedReminders) in
            guard let reminders = fetchedReminders else { return }
            let group = Dictionary(grouping: reminders, by: { (reminder) -> Date in
                return reminder.dueDateComponents?.date?.midnight ?? Date.distantFuture
            })
            self.eventCount = group.mapValues({ (reminders) -> Int in
                return reminders.count
            })
            completionHandler()
        }
    }

}
