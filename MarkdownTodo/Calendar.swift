//
//  Calendar.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import EventKit

class CalendarController {
    let store = EKEventStore.init()
    var calendars = [EKSource:[EKCalendar]]()
    var sources = [EKSource]()

    func source(for section: Int) -> [EKCalendar] {
        let source = sources[section]
        return calendars[source]!
    }

    func calendar(for indexPath:  IndexPath) -> EKCalendar {
        let source = sources[indexPath.section]
        return calendars[source]![indexPath.row]
    }

    func setup() {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized:
            print("Authorized")
            fetch()
        case .denied:
            print("Denied")
        case .notDetermined:
            store.requestAccess(to: .reminder) { (granted, error) in
                if granted {
                    print("Granted")
                    self.fetch()
                } else {
                    print("Access Denied")
                }
            }
        case.restricted:
            print("Restricted")
        default:
            print("Unknown case")
        }
    }

    func fetchReminders(for calendar: EKCalendar, completionHandler: @escaping (_ result: [EKReminder]) -> Void) -> () {
        let pred = store.predicateForReminders(in: [calendar])
        store.fetchReminders(matching: pred) { (fetchedReminders) in
            if let newReminders = fetchedReminders {
                completionHandler(newReminders)
            }
        }
    }


    func fetch() {
        sources = store.sources.filter({ (source) -> Bool in
            source.sourceType != .birthdays
        })

        sources.forEach { (source) in

                calendars[source] = Array(source.calendars(for: .reminder))


        }
    }
}
