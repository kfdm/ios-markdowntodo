//
//  DetailViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class ReminderListViewController: UITableViewController {

    var container = CalendarController.shared
    var tableData = GroupedReminders.init()
    var showCompleted = false

    func configureView() {
        guard let calendar = selectedCalendar else { return }
        self.title = calendar.title

        container.predicateForReminders(in: calendar) { (newReminders) in
            self.tableData = self.showCompleted ? GroupedReminders.init(reminders: newReminders) : GroupedReminders.init(reminders: newReminders.filter({ (r) -> Bool in
                return !r.isCompleted
            }))

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func toggleShowCompleted(_ sender: UISwitch) {
        showCompleted = sender.isOn
        configureView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(tableViewCell: ReminderViewCell.self)
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }

    var selectedCalendar: EKCalendar? {
        didSet {
            // Update the view.
            configureView()
        }
    }

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

    func actionSchedule(action: UITableViewRowAction, index: IndexPath) {
        let reminder = self.tableData.reminderForRowAt(index)
        let alert = UIAlertController(title: "Set Due", message: "Set Due of Reminder", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Unset", style: .default, handler: { (_) in
            reminder.dueDateComponents = nil
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Today", style: .default, handler: { (_) in
            let date = Date()
            let calendar = Calendar.current
            reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Tomorrow", style: .default, handler: { (_) in
            var dateComponent = DateComponents()
            dateComponent.day = 1
            let date = Calendar.current.date(byAdding: dateComponent, to: Date())!

            let calendar = Calendar.current
            reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func actionPriority(action: UITableViewRowAction, index: IndexPath) {
        let reminder = self.tableData.reminderForRowAt(index)
        let alert = UIAlertController(title: "Set Priority", message: "Set Priority of Reminder", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Unset", style: .destructive, handler: { (_) in
            reminder.priority = Priority.Unset.rawValue
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Low", style: .default, handler: { (_) in
            reminder.priority = Priority.Low.rawValue
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Medium", style: .default, handler: { (_) in
            reminder.priority = Priority.Medium.rawValue
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "High", style: .default, handler: { (_) in
            reminder.priority = Priority.High.rawValue
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let schedule = UITableViewRowAction(style: .normal, title: "Schedule", handler: actionSchedule)
        schedule.backgroundColor=UIColor.blue
        let priority = UITableViewRowAction(style: .normal, title: "Priority", handler: actionPriority)
        priority.backgroundColor = UIColor.orange
        return [schedule, priority]
    }

    // MARK: - Segues

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reminder = tableData.reminderForRowAt(indexPath)
        let controller = ReminderEditViewController.instantiate()
        controller.currentReminder = reminder
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Actions

    @IBAction func actionNewReminder(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: "New Reminder", message: "Please enter new reminder", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "New Todo"
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "New", style: .default, handler: { (_) in
            guard let selectedCalendar = self.selectedCalendar else { return }
            let reminder = self.container.newReminder(for: selectedCalendar)
            reminder.title = alert.textFields?.first?.text
            self.container.save(reminder: reminder, commit: true)
            self.configureView()
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
