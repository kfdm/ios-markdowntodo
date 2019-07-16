//
//  ReminderViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/12.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class ReminderViewCell: UITableViewCell {
    @IBOutlet weak var colorStrip: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCheckbox: UIImageView!

    func update(_ reminder: EKReminder) {
        self.titleLabel?.text = reminder.title
        let now = Date.init()

        switch reminder {
        case _ where reminder.isCompleted:
            let dateformat = DateFormatter()
            dateformat.dateStyle = .full
            self.dateLabel?.text = dateformat.string(from: reminder.completionDate!)
        default:
            self.dateLabel?.text = ""

            if let comp = reminder.dueDateComponents, let date = comp.date, date > now {
                self.accessoryType = .detailButton
            } else {
                self.accessoryType = .none
            }
        }

        colorStrip.backgroundColor = Colors.priority(for: reminder)
    }
}

extension EKReminder {
    func isOverdue() -> Bool {
        if isCompleted {return false}
        if dueDateComponents == nil {return false}
        return true
    }
}
