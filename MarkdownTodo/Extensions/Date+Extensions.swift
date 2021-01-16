//
//  Date+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    var endOfDay: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }

    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self.startOfDay)!
    }
    var isSentinel: Bool {
        return Calendar.current.isDate(self, equalTo: .distantFuture, toGranularity: .day)
    }

    func nextDate(dayOfTheWeek: Int) -> Date? {
        let calendar = Calendar.current
        let weekday = DateComponents(calendar: Calendar.current, weekday: dayOfTheWeek)
        return calendar.nextDate(after: self, matching: weekday, matchingPolicy: .nextTime)
    }
}

extension Calendar {
    func endOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }

    func dateComponents(from date: Date?) -> DateComponents? {
        if let date = date {
            return dateComponents([.year, .month, .day, .hour, .minute], from: date)
        }
        return nil
    }
}

extension DateFormatter {
    static var dateAndTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    static var fullDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}
