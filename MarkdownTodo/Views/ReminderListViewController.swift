//
//  DetailViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class ReminderListViewController: UITableViewController, Storyboarded {
    private var tableData = GroupedRemindersByDate()
    private var showCompleted = false

    var selectedPredicate: NSPredicate? {
        didSet {
            fetchReminders()
        }
    }

    var selectedCalendar: EKCalendar? {
        didSet {
            // Update the view.
            fetchReminders()
        }
    }

    private let myRefreshControl = UIRefreshControl()

    @objc func fetchReminders() {
        guard let pred = selectedPredicate else { return }

        GroupedRemindersByDate.remindersForPredicate(predicate: pred) { (reminders) in
            self.tableData = reminders

            DispatchQueue.main.async {
                self.myRefreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func toggleShowCompleted(_ sender: UISwitch) {
        showCompleted = sender.isOn
        fetchReminders()
    }

    func actionSchedule(action: UITableViewRowAction, index: IndexPath) {
        let reminder = tableData.reminderForRowAt(index)
        let alert = UIAlertController(title: "Set Due", message: "Set Due of Reminder", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Unset", style: .default, handler: { (_) in
            reminder.dueDateComponents = nil
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))

        alert.addAction(UIAlertAction(title: "Today", style: .default, handler: { (_) in
            let date = Date()
            let calendar = Calendar.current
            reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))

        alert.addAction(UIAlertAction(title: "Tomorrow", style: .default, handler: { (_) in
            var dateComponent = DateComponents()
            dateComponent.day = 1
            let date = Calendar.current.date(byAdding: dateComponent, to: Date())!

            let calendar = Calendar.current
            reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func actionPriority(action: UITableViewRowAction, index: IndexPath) {
        let reminder = tableData.reminderForRowAt(index)
        let alert = UIAlertController(title: "Set Priority", message: "Set Priority of Reminder", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Unset", style: .destructive, handler: { (_) in
            reminder.priority = 0
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))

        for i in 1...9 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { (_) in
                reminder.priority = i
                CalendarController.shared.save(reminder: reminder, commit: true)
                self.fetchReminders()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func actionDelete(action: UITableViewRowAction, index: IndexPath) {
        let reminder = tableData.reminderForRowAt(index)
        let alert = UIAlertController(title: "Delete Reminder", message: "Are you sure you want to delete", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            try? CalendarController.shared.store.remove(reminder, commit: true)
            self.fetchReminders()
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    func showReminder(_ reminder: EKReminder, animated: Bool) {
        let controller = ReminderEditViewController.instantiate()
        controller.currentReminder = reminder
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        navigationController?.pushViewController(controller, animated: animated)
    }

    // MARK: - Actions

    @IBAction func actionNewReminder(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: "New Reminder", message: "Please enter new reminder", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "New Todo"
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Save", style: .default, handler: { (_) in
            guard let selectedCalendar = self.selectedCalendar else { return }
            let reminder = CalendarController.shared.newReminder(for: selectedCalendar)
            reminder.title = alert.textFields?.first?.text
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))
        alert.addAction(UIAlertAction.init(title: "Save and Edit", style: .default, handler: { (_) in
            guard let selectedCalendar = self.selectedCalendar else { return }
            let reminder = CalendarController.shared.newReminder(for: selectedCalendar)
            reminder.title = alert.textFields?.first?.text
            CalendarController.shared.save(reminder: reminder, commit: true)
            self.showReminder(reminder, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - Lifecycle
extension ReminderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = myRefreshControl
        myRefreshControl.addTarget(self, action: #selector(fetchReminders), for: .valueChanged)

        tableView.registerReusableCell(tableViewCell: ReminderViewCell.self)
        fetchReminders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchReminders()
    }
}

// MARK: - UITableViewDataSource
extension ReminderListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.numberOfRowsInSection(section)

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.numberOfSections
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderViewCell.self, for: indexPath)
        let reminder = tableData.reminderForRowAt(indexPath)
        cell.update(reminder)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        let date = tableData.section(section)
        header.textLabel?.textColor = Colors.isOverdue(for: date)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = tableData.section(section)
        switch date {
        case Date.distantFuture:
            return "Unscheduled"
        default:

            let format = DateFormatter()
            format.locale = .current
            format.dateStyle = .full
            return format.string(from: date)
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = tableData.reminderForRowAt(indexPath)
        showReminder(reminder, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let schedule = UITableViewRowAction(style: .normal, title: "Schedule", handler: actionSchedule)
        schedule.backgroundColor=UIColor.blue
        let priority = UITableViewRowAction(style: .normal, title: "Priority", handler: actionPriority)
        priority.backgroundColor = UIColor.orange
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: actionDelete)
        delete.backgroundColor =  UIColor.red
        return [delete, schedule, priority]
    }
}
