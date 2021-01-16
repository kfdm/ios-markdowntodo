//
//  EventStore.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import Foundation
import os.log

class EventStore: ObservableObject {
    let eventStore = EKEventStore()

    var authorized: Bool {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            eventStore.requestAccess(to: .reminder) { (granted, error) in
                os_log(.debug, log: .event, "Granted access %s", granted.description)
                self.objectWillChange.send()
            }
            return false
        case .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func checkAccess() {
        os_log(.debug, log: .event, "Checking access: %s", authorized.description)
    }

    var sources: [EKSource] {
        return eventStore.sources  //.filter { $0.sourceType == .calDAV }
            .sorted { $0.title < $1.title }

    }

    func calendars(for source: EKSource) -> [EKCalendar] {
        return eventStore.calendars(for: .reminder)
            .filter { source.title == $0.source.title }
            .sorted { $0.title < $1.title }
    }

    private func calendar(named: String) -> EKCalendar? {
        return eventStore.calendars(for: .reminder).filter { $0.title == named }.first
    }

    var defaultCalendar: EKCalendar? {
        // TODO: Fix actual default calendar
        return calendar(named: "Inbox")
    }

    func toggleComplete(_ reminder: EKReminder) {
        os_log(.debug, log: .event, "Toggle Reminder %s", reminder.debugDescription)
        if reminder.isCompleted {
            reminder.completionDate = nil
        } else {
            reminder.completionDate = Date()
        }
        save(reminder)
    }

    func new(for calendar: EKCalendar) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = ""
        reminder.calendar = eventStore.calendar(withIdentifier: calendar.calendarIdentifier)
        return reminder
    }
}

// MARK:- Some lower level queries where we need to worry about Queues
extension EventStore {
    func save(_ reminder: EKReminder) {
        DispatchQueue.global(qos: .userInitiated).async {
            os_log(.debug, log: .event, "Saving Reminder %s", reminder.debugDescription)
            try? self.eventStore.save(reminder, commit: true)
            self.notifyRefresh()
        }
    }

    func save(_ calendar: EKCalendar) {
        DispatchQueue.global(qos: .userInitiated).async {
            os_log(.debug, log: .event, "Saving Calendar %s", calendar.debugDescription)
            try? self.eventStore.saveCalendar(calendar, commit: true)
            self.notifyRefresh()
        }
    }

    func remove(_ reminder: EKReminder) {
        DispatchQueue.global(qos: .userInitiated).async {
            os_log(.debug, log: .event, "Removing Reminder %s", reminder.debugDescription)
            try? self.eventStore.remove(reminder, commit: true)
            self.notifyRefresh()
        }
    }

    private func notifyRefresh() {
        DispatchQueue.main.async {
            os_log(.debug, log: .event, "Calling refresh")
            self.objectWillChange.send()
        }
    }
}

// MARK:- Some lower level queries to convert NSPredicate to Publisher
extension EventStore {
    typealias EKReminderPublisher = PassthroughSubject<[EKReminder], Never>

    func publisher(for predicate: NSPredicate) -> EKReminderPublisher {
        let publisher = EKReminderPublisher()
        DispatchQueue.global(qos: .userInitiated).async {
            os_log(.debug, log: .predicate, "Fetching predicate %s", predicate.description)
            self.eventStore.fetchReminders(matching: predicate) { fetchedReminders in
                let reminders = fetchedReminders ?? []
                os_log(.debug, log: .predicate, "%d reminders for %s", reminders.count, predicate.description)
                publisher.send(reminders)
                publisher.send(completion: .finished)
            }
        }
        return publisher
    }

    func reminders(for interval: DateInterval) -> NSPredicate {
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: interval.start, ending: interval.end, calendars: nil)
    }

    func incompleteReminders() -> NSPredicate {
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: nil, calendars: nil)
    }

    func reminders(for calendar: EKCalendar) -> NSPredicate {
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: nil, calendars: [calendar])
    }

    func reminders(for date: Date) -> NSPredicate {
        let start = date.startOfDay
        let end = date.endOfDay
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: start, ending: end, calendars: nil)
    }
}

// MARK:- Some useful preselected queries
extension EventStore {
    func completeReminders(for date: Date = Date()) -> NSPredicate {
        let start = date.startOfDay
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        return eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: start, ending: end, calendars: nil)
    }

    func scheduledReminders() -> NSPredicate {
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: .distantPast, ending: .distantFuture, calendars: nil)
    }

    func upcomingReminders(days: Int, start: Date = Date().startOfDay) -> NSPredicate {
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: start, ending: end, calendars: nil)
    }

    func agendaReminders() -> NSPredicate {
        let ending = Calendar.current.date(byAdding: .day, value: 3, to: Date())
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: ending, calendars: nil)
    }
}
