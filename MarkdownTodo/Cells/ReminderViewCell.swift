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
            default:
                dateSelector.setTitle(dateformat.string(from: newReminder.sortableDate), for: .normal)
            }

            switch newReminder.scheduledState {
            case .completed:
                statusButton.setImage(UIImage(named: "statusDone"), for: .normal)
            case .overdue:
                statusButton.setImage(UIImage(named: "statusOverdue"), for: .normal)
            default:
                statusButton.setImage(UIImage(named: "statusEmpty"), for: .normal)
            }
            statusButton.imageView?.contentMode = .scaleAspectFill

            dateSelector.setTitleColor(newReminder.scheduledState == .overdue ? UIColor.red : UIColor.black, for: .normal)

            colorStrip.backgroundColor = Colors.priority(for: newReminder)
        }
    }

    @IBAction func priorityClick(_ sender: UIButton) {
        delegate?.showPriorityDialog(reminder: reminder!)
    }
    @IBAction func dateClick(_ sender: UIButton) {
        delegate?.showScheduleDialog(reminder: reminder!)
    }
    @IBAction func actionClick(_ sender: UIButton) {
        delegate?.showStatusDialog(reminder: reminder!)
    }
}
