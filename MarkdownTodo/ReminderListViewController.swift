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

    var container = CalendarController()
    var tableData = GroupedReminders.init()
    var showCompleted = false

    func configureView() {
        guard let calendar = detailItem else { return }

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
        configureView()
    }

    var detailItem: EKCalendar? {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReminderViewCell
        let reminder = tableData.reminderForRowAt(indexPath)
        cell.update(reminder)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        let date = tableData.section(section)
        header.textLabel?.textColor = date < Date.init() ? UIColor.red : UIColor.black
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

    func actionToday(action: UITableViewRowAction, index: IndexPath) {
        let reminder = self.tableData.reminderForRowAt(index)
        let date = Date()
        let calendar = Calendar.current
        reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        container.save(reminder: reminder, commit: true)
        configureView()
    }

    func actionUnschedule(action: UITableViewRowAction, index: IndexPath) {
        let reminder = self.tableData.reminderForRowAt(index)
        reminder.dueDateComponents = nil
        container.save(reminder: reminder, commit: true)
        configureView()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .normal, title: "Today", handler: actionToday),
            UITableViewRowAction(style: .destructive, title: "Unschedule", handler: actionUnschedule)
        ]
    }
}
