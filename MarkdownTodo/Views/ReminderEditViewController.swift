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
    var currentReminder: EKReminder?
    weak var delegate: ReminderActions?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StringViewCell.self)
        tableView.register(PriorityViewCell.self)
        tableView.register(MarkdownViewCell.self)
        tableView.register(DateViewCell.self)
        self.title = NSLocalizedString("Edit Reminder", comment: "Edit Reminder Title")

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        navigationItem.leftItemsSupplementBackButton = true
    }

    @objc func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveEdit() {
        guard let reminder = currentReminder else { return }
        CalendarAPI.shared.save(reminder: reminder, commit: true)
        dismiss(animated: true, completion: nil)
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
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Title", comment: "Reminder Title")
            cell.value = currentReminder?.title
            cell.textChanged = { newTitle in self.currentReminder?.title = newTitle }
            return cell
        case .url:
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("URL", comment: "Reminder URL")
            cell.value = currentReminder?.url?.absoluteString
            cell.keyboardType = .URL
            cell.textChanged = { newURL in self.currentReminder?.url = URL(string: newURL) }
            return cell
        case .priority:
            let cell: PriorityViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.priority = currentReminder!.priority
            cell.changed = { newPriority in self.currentReminder?.priority = newPriority }
            return cell
        case .due:
            let cell: DateViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Due", comment: "Due Date")
            cell.date = currentReminder?.dueDateComponents
            cell.changed = { newDate in self.currentReminder?.dueDateComponents = newDate }
            return cell
        case .notes:
            let cell: MarkdownViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Notes", comment: "Reminder Notes")
            cell.value = currentReminder?.notes ?? ""
            cell.changed = { newNote in self.currentReminder?.notes = newNote }
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
}
