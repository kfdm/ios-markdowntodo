//
//  DetailViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class DetailViewController: UITableViewController {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let reminder = tableData.reminderForRowAt(indexPath)
        cell.textLabel?.text =  reminder.title
        cell.detailTextLabel?.text = "\(reminder.creationDate)"
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = tableData.section(section)
        switch date {
        case Date.distantFuture:
            return "Unscheduled"
        default:
            let format = DateFormatter()
            format.dateStyle = .full
            return format.string(from: date)
        }

    }
}
