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
    var reminders = [EKReminder]()
    var completed = [EKReminder]()
    var showCompleted = true

    func configureView() {
        guard let calendar = detailItem else { return }

        container.fetchReminders(for: calendar) { (newReminders) in
            print(newReminders)
            self.reminders = newReminders.filter({ (reminder) -> Bool in
                return !reminder.isCompleted
            })
            self.completed = newReminders.filter({ (reminder) -> Bool in
                return reminder.isCompleted
            })

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
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: EKCalendar? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return reminders.count
        case 1:
            return completed.count
        default:
            return 0
        }

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return showCompleted ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch indexPath.section {
        case 0:
            let reminder = reminders[indexPath.row]
            cell.textLabel?.text =  reminder.title
            cell.detailTextLabel?.text = "\(reminder.creationDate)"

        case 1:
            let reminder = completed[indexPath.row]
            cell.textLabel?.text =  reminder.title
            cell.detailTextLabel?.text = "\(reminder.creationDate)"

        default:
            return cell
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Reminders"
        case 1:
            return "Completed"
        default:
            return "Unknown"
        }
    }
}
