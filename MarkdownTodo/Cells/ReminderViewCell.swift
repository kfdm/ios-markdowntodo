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
    @IBOutlet weak var dateSelector: UIButton!

    @IBOutlet weak var statusButton: UIButton!

    @IBOutlet weak var colorStrip: UIButton!

    @IBAction func actionClick(_ sender: UIButton) {
        print("Clicked button \(sender)")
    }

    weak var delegate: ReminderActions?

    var reminder: EKReminder? {
        didSet {
            guard let newReminder = reminder else { return }
            titleLabel?.text = newReminder.title

            let dateformat = DateFormatter()
            dateformat.dateStyle = .short

            switch newReminder.scheduledState {
            case .unscheduled:
                dateSelector.setTitle("Unscheduled", for: .normal)
            case .completed:
                dateSelector.setTitle(dateformat.string(from: newReminder.completionDate!), for: .normal)
            default:
                dateSelector.setTitle(dateformat.string(from: (newReminder.dueDateComponents?.date)!), for: .normal)
            }

            dateSelector.setTitleColor(newReminder.scheduledState == .overdue ? UIColor.red : UIColor.black, for: .normal)

            colorStrip.backgroundColor = Colors.priority(for: newReminder)
        }
    }

    @IBAction func priorityClick(_ sender: UIButton) {
        delegate?.priorityFor(reminder: reminder!)
    }
    @IBAction func dateClick(_ sender: UIButton) {
        delegate?.scheduleFor(reminder: reminder!)
    }
}
