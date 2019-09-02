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
        let vc = ReminderEditViewController.instantiate()
        let navigation = UINavigationController(rootViewController: vc)
        vc.currentReminder = reminder
        vc.didSelect = {
            CalendarAPI.shared.save(reminder: $0, commit: true)
        }
        vc.didCancel = {
            reminder.reset()
        }
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
        guard let selectedCalendar = self.selectedCalendars.first else { return }
        let newReminder = CalendarAPI.shared.newReminder(for: selectedCalendar)
        self.showReminder(newReminder, animated: true)
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
    func showList(reminder: EKReminder) {
        // TODO: Fix a better solution
        guard selectedCalendars.first != reminder.calendar else { return }

        let predicate = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [reminder.calendar])
        let vc = ReminderListViewController.instantiate()
        vc.selectedCalendars = [reminder.calendar]
        vc.selectedPredicate = predicate
        navigationController?.pushViewController(vc, animated: true)
    }

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
        let vc = DatePickerViewController.instantiate()
        let navigation = UINavigationController(rootViewController: vc)

        vc.currentDate = reminder.dueDateComponents
        vc.didSelect = {
            reminder.dueDateComponents = $0
            CalendarAPI.shared.save(reminder: reminder, commit: true)
            vc.dismiss(animated: true, completion: nil)
        }
        vc.didCancel = {
            vc.dismiss(animated: true, completion: nil)
        }

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
