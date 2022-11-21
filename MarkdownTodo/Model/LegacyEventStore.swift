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
import EventKitExtensions

class MarkdownEventStore: CalendarStore {
    static var shared = MarkdownEventStore()
    private let store : EKEventStore
    private let logger : Logger

    init() {
        self.store = .init()
        self.logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "MarkdownEventStore")
        super.init(
            store: self.store,
            logger: self.logger
        )
    }

    var defaultCalendar: EKCalendar? {
        return store.defaultCalendarForNewReminders()
    }
}

class LegacyEventStore: ObservableObject {
    private let eventStore = EKEventStore()
    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LegacyEventStore")

    func refreshSourcesIfNecessary() {
        eventStore.refreshSourcesIfNecessary()
        objectWillChange.send()
    }

    func calendars(for source: EKSource) -> [EKCalendar] {
        return source.calendars(for: .reminder)
            .filter { source.sourceIdentifier == $0.source.sourceIdentifier }
            .sorted { $0.title < $1.title }
    }

    var defaultCalendar: EKCalendar? {
        return eventStore.defaultCalendarForNewReminders()
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
extension LegacyEventStore {
    private func wrapAsync(queue: DispatchQueue, completion: @escaping () throws -> Void) {
        queue.async {
            do {
                try completion()
            } catch let error {
                os_log(.debug, log: .event, "%s", error.localizedDescription)
            }
        }
    }

    func save(_ reminder: EKReminder) {
        save([reminder])
    }

    func save(_ reminders: [EKReminder]) {
        wrapAsync(queue: .global(qos: .userInitiated)) {
            os_log(.debug, log: .event, "Saving Reminders %s", reminders.debugDescription)
            try self.eventStore.save(reminders, commit: true)
            self.notifyRefresh()
        }
    }

    func save(_ calendar: EKCalendar) {
        wrapAsync(queue: .global(qos: .userInitiated)) {
            os_log(.debug, log: .event, "Saving Calendar %s", calendar.debugDescription)
            try self.eventStore.saveCalendar(calendar, commit: true)
            self.notifyRefresh()
        }
    }

    func remove(_ reminder: EKReminder) {
        remove([reminder])
    }

    func remove(_ reminders: [EKReminder]) {
        wrapAsync(queue: .global(qos: .userInitiated)) {
            try self.eventStore.remove(reminders, commit: true)
            self.notifyRefresh()
        }
    }

    private func notifyRefresh() {
        DispatchQueue.main.async {
            os_log(.debug, log: .event, "Calling refresh")
            self.eventStore.refreshSourcesIfNecessary()
            self.objectWillChange.send()
        }
    }
}

// MARK:- Some lower level queries to convert NSPredicate to Publisher
extension LegacyEventStore {
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
}

// MARK:- Some useful preselected queries
extension LegacyEventStore {
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

    func completed(for calendar: EKCalendar) -> NSPredicate {
        return eventStore.predicateForCompletedReminders(withCompletionDateStarting: nil, ending: nil, calendars: [calendar])
    }

    func reminders(for date: Date) -> NSPredicate {
        let start = date.startOfDay
        let end = date.endOfDay
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: start, ending: end, calendars: nil)
    }

    func completeReminders(for date: Date = Date()) -> NSPredicate {
        let start = date.startOfDay
        let end = date.endOfDay
        return eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: start, ending: end, calendars: nil)
    }

    func scheduledReminders() -> NSPredicate {
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: .distantPast, ending: .distantFuture, calendars: nil)
    }

    func upcomingReminders(days: Int = 3) -> NSPredicate {
        let ending = Calendar.current.date(byAdding: .day, value: days, to: Date())
        return eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: ending, calendars: nil)
    }
}

extension OSLog {
    fileprivate static var predicate = OSLog.init(
        subsystem: Bundle.main.bundleIdentifier!, category: "Predicate")
    fileprivate static var event = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "EventStore")
}

extension MarkdownEventStore {
    func scheduledReminders() async -> [EKReminder] {
        return await incomplete(from: .distantPast, to: .distantFuture)
    }
    func upcomingReminders(days: Int = 3) async -> [EKReminder] {
        let ending = Calendar.current.date(byAdding: .day, value: days, to: Date())
        return await incomplete(from: nil, to: ending)
    }

    func save(_ calendar: EKCalendar) {
        try? self.store.saveCalendar(calendar, commit: true)
        self.objectWillChange.send()
    }

    func reminders(for interval: DateInterval) async -> [EKReminder] {
        return await incomplete(from: interval.start, to: interval.end)
    }
}
