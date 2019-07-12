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
    func update(_ reminder: EKReminder) {
        self.textLabel?.text = reminder.title
        let now = Date.init()

        switch reminder {
        case _ where reminder.isCompleted:
            let dateformat = DateFormatter()
            dateformat.dateStyle = .full
            self.detailTextLabel?.text = dateformat.string(from: reminder.completionDate!)
        default:
            self.detailTextLabel?.text = ""

            if let comp = reminder.dueDateComponents, let date = comp.date, date > now {
                self.accessoryType = .detailButton
            } else {
                self.accessoryType = .none
            }
        }
    }
}
