//
//  ReminderEditViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

enum TableRows: Int {
    case title = 0
    case url
    case priority
    case due
    case notes
}

class ReminderEditViewController: UITableViewController, Storyboarded {
    var container = CalendarController.shared
    var currentReminder: EKReminder? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        StringViewCell.register(tableView)
        PriorityViewCell.register(tableView)
        TextViewCell.register(tableView)
        self.title = NSLocalizedString("Edit Reminder", comment: "Edit Reminder Title")
        configureView()
    }

    func configureView() {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableRows.init(rawValue: indexPath.row)! {
        case .title:
            let cell = StringViewCell.dequeueReusableCell(tableView)
            cell.labelField.text = NSLocalizedString("Title", comment: "Reminder Title")
            cell.textField.text = currentReminder?.title
            return cell
        case .url:
            let cell = StringViewCell.dequeueReusableCell(tableView)
            cell.labelField.text = NSLocalizedString("URL", comment: "Reminder URL")
            cell.textField.text = currentReminder?.url?.absoluteString
            cell.textField.keyboardType = .URL
            return cell
        case .priority:
            let cell = PriorityViewCell.dequeueReusableCell(tableView)
            cell.setPriority(for: currentReminder!)
            cell.selectorPriority.addTarget(self, action: #selector(updatedPriority(_:)), for: .valueChanged)
            return cell
        case .due:
            let cell = StringViewCell.dequeueReusableCell(tableView)
            cell.labelField.text = NSLocalizedString("Due", comment: "Due Date")
            cell.textField.text = "<date> \(currentReminder?.dueDateComponents)"
            return cell
        case .notes:
            let cell = TextViewCell.dequeueReusableCell(tableView)
            cell.labelField.text = NSLocalizedString("Notes", comment: "Reminder Notes")
            cell.textField.text = currentReminder?.notes
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableRows.init(rawValue: indexPath.row)! {
        case .notes:
            return 256
        default:
            return 44
        }
    }

    // MARK: Selectors

    @objc func updatedPriority(_ sender: UISegmentedControl) {
        guard let reminder = currentReminder else { return }
        reminder.priority = PriorityViewCell.getPriority(for: sender)
        container.save(reminder: reminder, commit: true)
    }
}
