//
//  ReminderEditViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class ReminderEditViewController: UITableViewController, Storyboarded {
    var currentReminder: EKReminder!
    weak var delegate: ReminderActions?

    var didSelect: ((EKReminder) -> Void)? {
        didSet {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        }
    }

    var didCancel: (() -> Void)? {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StringViewCell.self)
        tableView.register(PriorityViewCell.self)
        tableView.register(MarkdownViewCell.self)
        tableView.register(DateViewCell.self)
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "SimpleTableView")
        self.title = NSLocalizedString("Edit Reminder", comment: "Edit Reminder Title")
    }

    @objc func saveEdit() {
        didSelect?(currentReminder)
        dismiss(animated: true, completion: nil)
    }

    @objc func cancelEdit() {
        didCancel?()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        case 2:
            return 1
        default:
            fatalError("Unknown section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Title", comment: "Reminder Title")
            cell.value = currentReminder?.title
            cell.textChanged = { [unowned self] newTitle in self.currentReminder?.title = newTitle }
            return cell
        case [0, 1]:
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("URL", comment: "Reminder URL")
            cell.value = currentReminder?.url?.absoluteString
            cell.keyboardType = .URL
            cell.textChanged = { [unowned self] newURL in self.currentReminder?.url = URL(string: newURL) }
            return cell
        case [0, 2]:
            let cell: PriorityViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.priority = currentReminder!.priority
            cell.changed = { [unowned self] newPriority in self.currentReminder?.priority = newPriority }
            return cell
        case [0, 3]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableView", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Calendar", comment: "Currently selected calendar")
            cell.detailTextLabel?.text = currentReminder?.calendar.title
            cell.detailTextLabel?.textColor = Colors.calendar(for: currentReminder!.calendar)
            cell.accessoryType = .disclosureIndicator
            return cell

        case [1, 0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableView", for: indexPath)
            cell.textLabel?.text  = NSLocalizedString("Start", comment: "Start Date")
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.textColor = UIColor.black
            if let date = currentReminder?.startDateComponents?.date {
                cell.detailTextLabel?.text  = Formats.full(date)
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Unscheduled", comment: "Due Date")
            }
            return cell
        case [1, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableView", for: indexPath)
            cell.textLabel?.text  = NSLocalizedString("Due", comment: "Due Date")
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.textColor = UIColor.black
            if let date = currentReminder?.dueDateComponents?.date {
                cell.detailTextLabel?.text  = Formats.full(date)
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Unscheduled", comment: "Due Date")
            }
            return cell

        case [2, 0]:
            let cell: MarkdownViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Notes", comment: "Reminder Notes")
            cell.value = currentReminder?.notes ?? ""
            cell.changed = { [unowned self] newNote in self.currentReminder?.notes = newNote }
            return cell
        default:
            fatalError("Invalid indexpath \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [2, 0]:
            return 256
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 3]:
            let vc = SelectCalendarViewController(for: currentReminder?.calendar)
            vc.didSelect = { calendar in
                self.currentReminder.calendar = calendar
                CalendarAPI.shared.save(reminder: self.currentReminder, commit: true)
                tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        case [1, 0]:
            let vc = DatePickerViewController.instantiate()
            vc.currentDate = currentReminder.startDateComponents
            vc.didSelect = {
                self.navigationController?.popViewController(animated: true)
                self.currentReminder.startDateComponents = $0
                CalendarAPI.shared.save(reminder: self.currentReminder, commit: true)
                tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        case [1, 1]:
            let vc = DatePickerViewController.instantiate()
            vc.currentDate = currentReminder.dueDateComponents
            vc.didSelect = {
                self.navigationController?.popViewController(animated: true)
                self.currentReminder.dueDateComponents = $0
                CalendarAPI.shared.save(reminder: self.currentReminder, commit: true)
                tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("no select action for \(indexPath)")
        }
    }
}
