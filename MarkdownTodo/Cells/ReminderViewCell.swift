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
    @IBOutlet weak var statusButton: UIButton!

    @IBAction func actionClick(_ sender: UIButton) {
        print("Clicked button \(sender)")
    }

    func update(_ reminder: EKReminder) {
        self.titleLabel?.text = reminder.title
        self.titleLabel.textColor = reminder.isOverdue() ? UIColor.red : UIColor.black

        switch reminder {
        case _ where reminder.isCompleted:
            let dateformat = DateFormatter()
            dateformat.dateStyle = .full
            self.dateLabel?.text = dateformat.string(from: reminder.completionDate!)
        default:
            self.dateLabel?.text = ""
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
