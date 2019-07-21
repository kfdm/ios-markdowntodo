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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!

    @IBOutlet weak var colorStrip: UIButton!

    @IBAction func actionClick(_ sender: UIButton) {
        print("Clicked button \(sender)")
    }

    weak var delegate : ReminderActions?

    var reminder : EKReminder? {
        didSet {
            guard let newReminder = reminder else { return }
            titleLabel?.text = newReminder.title
            titleLabel.textColor = newReminder.isOverdue() ? UIColor.red : UIColor.black

            switch reminder {
            case _ where reminder!.isCompleted:
                let dateformat = DateFormatter()
                dateformat.dateStyle = .full
                self.dateLabel?.text = dateformat.string(from: newReminder.completionDate!)
            default:
                self.dateLabel?.text = ""
            }

            colorStrip.backgroundColor = Colors.priority(for: newReminder)
        }
    }

    @IBAction func priorityClick(_ sender: UIButton) {
        delegate?.priorityFor(reminder: reminder!)
    }

}

extension EKReminder {
    func isOverdue() -> Bool {
        if isCompleted {return false}
        guard let dueDate = dueDateComponents?.date else { return false}
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return dueDate < date
    }
}
