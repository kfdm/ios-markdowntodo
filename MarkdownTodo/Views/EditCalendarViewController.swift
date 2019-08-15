//
//  EditCalendarViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class EditCalendarViewController: UITableViewController {
    var calendar: EKCalendar

    init(for calendar: EKCalendar) {
        self.calendar = calendar
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("New Calendar", comment: "Edit Reminder Title")

        tableView.register(StringViewCell.self)
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 44.0

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        navigationItem.leftItemsSupplementBackButton = true
    }

    @objc func cancelEdit() {
        calendar.reset()
        dismiss(animated: true, completion: nil)
    }

    @objc func saveEdit() {
        CalendarAPI.shared.save(calendar: calendar, commit: true)
        CalendarAPI.shared.refreshSourcesIfNecessary()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Name"
            cell.value = calendar.title
            cell.textChanged = { self.calendar.title = $0 }
            return cell
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Color"
            cell.textLabel?.textColor = Colors.calendar(for: calendar)
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            fatalError("Unknown indexpath \(indexPath)")
        }
    }
}
