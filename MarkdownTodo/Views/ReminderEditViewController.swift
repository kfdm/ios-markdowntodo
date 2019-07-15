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
    var container = CalendarController.shared
    var currentReminder: EKReminder? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Title", comment: "Reminder Title")
            cell.detailTextLabel?.text = currentReminder?.title
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("URL", comment: "Reminder URL")
            cell.detailTextLabel?.text = currentReminder?.url?.absoluteString
            return cell
        case 2:
            let cell = PriorityViewCell.create(tableView, for: currentReminder!)
            cell.selectorPriority.addTarget(self, action: #selector(updatedPriority(_:)), for: .valueChanged)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)

            return cell
        }

    }

    // MARK: Selectors

    @objc func updatedPriority(_ sender: UISegmentedControl) {
        guard let reminder = currentReminder else { return }
        reminder.priority = PriorityViewCell.getPriority(for: sender)
        container.save(reminder: reminder, commit: true)
    }
}
