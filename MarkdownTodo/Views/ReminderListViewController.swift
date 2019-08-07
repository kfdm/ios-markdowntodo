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
    private var groupedReminders = [ReminderGroup]()

    var selectedPredicate: NSPredicate?
    var selectedCalendars = [EKCalendar]()

    // MARK: - Segues

    func showReminder(_ reminder: EKReminder, animated: Bool) {
        let scheduleController = ReminderEditViewController.instantiate()
        let navigation = UINavigationController(rootViewController: scheduleController)
        scheduleController.currentReminder = reminder
        scheduleController.delegate = self
        navigation.modalPresentationStyle = .formSheet
        present(navigation, animated: true, completion: nil)
    }

    // MARK: - Actions
    @IBAction func showCompleted(_ sender: UIButton) {
        let completedController = ReminderListViewController.instantiate()
        completedController.selectedCalendars = selectedCalendars
        completedController.selectedPredicate = CalendarAPI.shared.predicateForCompletedReminders(withDueDateStarting: nil, ending: nil, calendars: selectedCalendars)
        navigationController?.pushViewController(completedController, animated: true)
    }

    @IBAction func actionNewReminder(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: "New Reminder", message: "Please enter new reminder", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "New Todo"
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Save", style: .default, handler: { (_) in
            guard let selectedCalendar = self.selectedCalendars.first else { return }
            let reminder = CalendarAPI.shared.newReminder(for: selectedCalendar)
            reminder.title = alert.textFields?.first?.text
            CalendarAPI.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))
        alert.addAction(UIAlertAction.init(title: "Save and Edit", style: .default, handler: { (_) in
            guard let selectedCalendar = self.selectedCalendars.first else { return }
            let reminder = CalendarAPI.shared.newReminder(for: selectedCalendar)
            reminder.title = alert.textFields?.first?.text
            CalendarAPI.shared.save(reminder: reminder, commit: true)
            self.showReminder(reminder, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - Lifecycle
extension ReminderListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchReminders), for: .valueChanged)
        tableView.register(ReminderViewCell.self)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchReminders), name: .savedReminder, object: nil)
        fetchReminders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchReminders()
    }
}

// MARK: - UITableViewDataSource
extension ReminderListViewController {
    @objc func fetchReminders() {
        guard let pred = selectedPredicate else { return }
        CalendarAPI.shared.fetchReminders(matching: pred) { (fetchedReminders) in
            let grouped = ReminderManager.reminders(fetchedReminders, byGrouping: .date, orderedBy: .priority)

            DispatchQueue.main.async {
                self.groupedReminders = grouped
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedReminders[section].events.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedReminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReminderViewCell = tableView.dequeueReusableCell(for: indexPath)
        let reminder = groupedReminders[indexPath.section].events[indexPath.row]
        cell.reminder = reminder
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedReminders[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = groupedReminders[indexPath.section].events[indexPath.row]
        showReminder(reminder, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reminder = groupedReminders[indexPath.section].events[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, success in
            CalendarAPI.shared.remove(reminder, commit: true)
            success(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - ReminderActions
extension ReminderListViewController: ReminderActions {
    func showPriorityDialog(reminder: EKReminder) {
        let alert = UIAlertController(title: "Set Priority", message: "Set Priority of Reminder", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Unset", style: .destructive, handler: { (_) in
            reminder.priority = 0
            CalendarAPI.shared.save(reminder: reminder, commit: true)
            self.fetchReminders()
        }))

        for i in 1...9 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default, handler: { (_) in
                reminder.priority = i
                CalendarAPI.shared.save(reminder: reminder, commit: true)
                self.fetchReminders()
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showScheduleDialog(reminder: EKReminder) {
        let scheduleController = ReminderDatePickerViewController.instantiate()
        let navigation = UINavigationController(rootViewController: scheduleController)
        scheduleController.currentReminder = reminder
        scheduleController.delegate = self
        navigation.modalPresentationStyle = .formSheet
        present(navigation, animated: true, completion: nil)
    }
    func showStatusDialog(reminder: EKReminder) {
        if reminder.isCompleted {
            reminder.completionDate = nil
        } else {
            reminder.completionDate = Date()
        }
        CalendarAPI.shared.save(reminder: reminder, commit: true)
        self.fetchReminders()
    }
}
