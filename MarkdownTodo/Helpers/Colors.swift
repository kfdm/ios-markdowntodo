//
//  Colors.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class Colors {
    let PriorityLow = UIColor.blue
    let PriorityMed = UIColor.orange
    let PriorityHigh = UIColor.red

    let DateOverdue = UIColor.red

    static func priority(for reminder: EKReminder) -> UIColor {
        if let color = UIColor(named: "priority\(reminder.priority)") {
            return color
        }
        return UIColor.purple
    }

    static let dueColor = UIColor(named: "dueHeader")
    static let priorityLow = UIColor(named: "priority9")
    static let priorityMed = UIColor(named: "priority5")
    static let priorityHigh = UIColor(named: "priority1")

    static func isOverdue(for date: Date) -> UIColor {
        return date < Date.init() ? UIColor.red : UIColor.black
    }

    static func calendar(for cal: EKCalendar) -> UIColor {
        return UIColor(cgColor: cal.cgColor)
    }
}
