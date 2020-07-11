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
        return eventStore.sources.filter { $0.sourceType == .calDAV }
            .sorted { $0.title < $1.title }
    }

    func calendars(for source: EKSource) -> [EKCalendar] {
        eventStore.refreshSourcesIfNecessary()
        return eventStore.calendars(for: .reminder)
            .filter { source.title == $0.source.title }
            .sorted { $0.title < $1.title }
    }

    func reminders(for calendar: EKCalendar) -> ReminderQuery {
        let publisher = PassthroughSubject<[EKReminder], Never>()
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: nil, calendars: [calendar])

        eventStore.fetchReminders(matching: predicate) { (reminders) in
            publisher.send(reminders ?? [])
        }
        return publisher
    }

    func overdueReminders() -> ReminderQuery {
        let publisher = PassthroughSubject<[EKReminder], Never>()
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: Date(), calendars: nil)

        eventStore.fetchReminders(matching: predicate) { (reminders) in
            publisher.send(reminders ?? [])
        }
        return publisher
    }

    func todayReminders() -> ReminderQuery {
        let publisher = PassthroughSubject<[EKReminder], Never>()
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: Date(), ending: Date(), calendars: nil)

        eventStore.fetchReminders(matching: predicate) { (reminders) in
            publisher.send(reminders ?? [])
        }
        return publisher
    }
}

typealias ReminderQuery = PassthroughSubject<[EKReminder], Never>