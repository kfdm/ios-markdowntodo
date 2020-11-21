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
                print(granted)
            }
            return false
        case .restricted:
            return false
        @unknown default:
            return false
        }
    }

    var sources: [EKSource] {
        eventStore.refreshSourcesIfNecessary()
        return eventStore.sources  //.filter { $0.sourceType == .calDAV }
            .sorted { $0.title < $1.title }

    }

    func calendars(for source: EKSource) -> [EKCalendar] {
        eventStore.refreshSourcesIfNecessary()
        return eventStore.calendars(for: .reminder)
            .filter { source.title == $0.source.title }
            .sorted { $0.title < $1.title }
    }

    func toggleComplete(_ reminder: EKReminder) throws {
        print("Toggle reminder \(reminder)")
        if reminder.isCompleted {
            reminder.completionDate = nil
        } else {
            reminder.completionDate = Date()
        }
        try save(reminder)
    }

    func save(_ reminder: EKReminder) throws {
        print("Saving \(reminder)")
        try eventStore.save(reminder, commit: true)
        objectWillChange.send()
    }

    func new(for calendar: EKCalendar) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = ""
        reminder.calendar = eventStore.calendar(withIdentifier: calendar.calendarIdentifier)
        return reminder
    }
}

// MARK:- Some lower level queries to convert NSPredicate to Publisher
extension EventStore {
    typealias EKReminderPublisher = PassthroughSubject<[EKReminder], Never>

    func publisher(for predicate: NSPredicate) -> EKReminderPublisher {
        let publisher = PassthroughSubject<[EKReminder], Never>()
        eventStore.fetchReminders(matching: predicate) { (reminders) in
            publisher.send(reminders ?? [])
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
