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
    var container = CalendarController()
    var currentReminder: EKReminder? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)
            cell.textLabel?.text = "Title"
            cell.detailTextLabel?.text = currentReminder?.title
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)
            cell.textLabel?.text = "URL"
            cell.detailTextLabel?.text = currentReminder?.url?.absoluteString
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath)

            return cell
        }

    }
}
