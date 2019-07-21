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
    var container = CalendarManager.shared
    var currentReminder: EKReminder? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(tableViewCell: StringViewCell.self)
        tableView.registerReusableCell(tableViewCell: PriorityViewCell.self)
        tableView.registerReusableCell(tableViewCell: MarkdownViewCell.self)
        tableView.registerReusableCell(tableViewCell: DateViewCell.self)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: StringViewCell.self)
            cell.labelField.text = NSLocalizedString("Title", comment: "Reminder Title")
            cell.textField.text = currentReminder?.title
            return cell
        case .url:
            let cell = tableView.dequeueReusableCell(withIdentifier: StringViewCell.self)
            cell.labelField.text = NSLocalizedString("URL", comment: "Reminder URL")
            cell.textField.text = currentReminder?.url?.absoluteString
            cell.textField.keyboardType = .URL
            return cell
        case .priority:
            let cell = tableView.dequeueReusableCell(withIdentifier: PriorityViewCell.self)
            cell.setPriority(for: currentReminder!)
            cell.selectorPriority.addTarget(self, action: #selector(updatedPriority(_:)), for: .valueChanged)
            return cell
        case .due:
            let cell = tableView.dequeueReusableCell(withIdentifier: DateViewCell.self)
            cell.label = NSLocalizedString("Due", comment: "Due Date")
            cell.date = currentReminder?.dueDateComponents
            return cell
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: MarkdownViewCell.self)
            cell.label = NSLocalizedString("Notes", comment: "Reminder Notes")
            cell.value = currentReminder?.notes ?? ""
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableRows.init(rawValue: indexPath.row)! {
        case .notes:
            return 256
        case .due:
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
