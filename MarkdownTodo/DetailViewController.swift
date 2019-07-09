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

    func configureView() {
        guard let calendar = detailItem else { return }

        container.fetchReminders(for: calendar) { (newReminders) in
            print(newReminders)
            self.reminders = newReminders.filter({ (reminder) -> Bool in
                return !reminder.isCompleted
            })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        return reminders.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let reminder = reminders[indexPath.row]

        cell.textLabel?.text =  reminder.title
        cell.detailTextLabel?.text = "\(reminder.completionDate)"
        return cell
    }
}
