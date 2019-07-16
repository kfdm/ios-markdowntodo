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
        switch reminder.priority {
        case 0:
            return UIColor.lightGray
        case 1...3: // High
            return UIColor.red
        case 4...6: // Medium
            return UIColor.orange
        case 7...9: // Low
            return UIColor.blue
        default:
            return UIColor.black
        }
    }

    static func isOverdue(for date: Date) -> UIColor {
        return date < Date.init() ? UIColor.red : UIColor.black
    }

    static func calendar(for cal: EKCalendar) -> UIColor {
        return UIColor(cgColor: cal.cgColor)
    }
}
