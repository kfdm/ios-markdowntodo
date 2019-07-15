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
            return UIColor.clear
        case 4:
            return UIColor.blue
        case 6:
            return UIColor.orange
        default:
            print("Unknown priority \(priority)")
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
