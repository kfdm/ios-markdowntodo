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
        switch Priority.convert(rawValue: reminder.priority) {
        case .Unset:
            return UIColor.lightGray
        case .Low:
            return UIColor.blue
        case .Medium:
            return UIColor.orange
        case .High:
            return UIColor.red
        }
    }

    static func isOverdue(for date: Date) -> UIColor {
        return date < Date.init() ? UIColor.red : UIColor.black
    }

    static func calendar(for cal: EKCalendar) -> UIColor {
        return UIColor(cgColor: cal.cgColor)
    }
}
