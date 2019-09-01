//
//  ReminderViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/12.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class ReminderViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateSelector: UIButton!

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var listButton: UIButton!

    @IBOutlet weak var colorStrip: UIButton!

    weak var delegate: ReminderActions?

    var reminder: EKReminder? {
        didSet {
            guard let newReminder = reminder else { return }
            titleLabel?.text = newReminder.title

            listButton.setTitle(newReminder.calendar.title, for: .normal)
            listButton.setTitleColor(Colors.calendar(for: newReminder.calendar), for: .normal)

            switch newReminder.scheduledState {
            case .unscheduled:
                dateSelector.setTitle("-", for: .normal)
            default:
                dateSelector.setTitle(Formats.short(newReminder.sortableDate), for: .normal)
            }

            linkButton.isHidden = newReminder.url == nil

            switch newReminder.scheduledState {
            case .completed:
                statusButton.setImage(Images.statusDone, for: .normal)
            case .overdue:
                statusButton.setImage(Images.statusOverdue, for: .normal)
            case .repeating:
                statusButton.setImage(Images.statusRepeating, for: .normal)
            default:
                statusButton.setImage(Images.statusEmpty, for: .normal)
            }

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
    @IBAction func linkClick(_ sender: UIButton) {
        guard let url = reminder?.url else { return }
        UIApplication.shared.open(url)
    }
}
