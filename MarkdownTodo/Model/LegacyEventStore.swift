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

extension MarkdownEventStore {
    func scheduledReminders() async -> [EKReminder] {
        return await incomplete(from: .distantPast, to: .distantFuture)
    }
    func upcomingReminders(days: Int = 3) async -> [EKReminder] {
        let ending = Calendar.current.date(byAdding: .day, value: days, to: Date())
        return await incomplete(from: nil, to: ending)
    }

    func save(_ calendar: EKCalendar) {
        do {
            try self.store.saveCalendar(calendar, commit: true)
        } catch {
            print(error.localizedDescription)
        }
        self.objectWillChange.send()
    }

    func reminders(for interval: DateInterval) async -> [EKReminder] {
        return await incomplete(from: interval.start, to: interval.end)
    }

    func remove(_ reminders: [EKReminder]) {
        do {
            try self.store.remove(reminders, commit: true)
        } catch {
            print(error.localizedDescription)
        }
        self.objectWillChange.send()
    }

    func remove(_ reminder: EKReminder) {
        remove(reminders: [reminder])
    }

    func toggleComplete(_ reminder: EKReminder) {
        if reminder.isCompleted {
            reminder.completionDate = nil
        } else {
            reminder.completionDate = Date()
        }
        save(reminder)
    }
}
