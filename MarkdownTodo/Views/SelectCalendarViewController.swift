//
//  SelectCalendarViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

typealias SelectDelegate = ((EKCalendar) -> Void)

class SelectCalendarViewController: UITableViewController {
    var calendar: EKCalendar?
    var groupedCalendars = [CalendarGroup]()
    var didSelect: SelectDelegate?

    init(for calendar: EKCalendar?) {
        self.calendar = calendar
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self

        title = NSLocalizedString("Select Calendar", comment: "Select Calendar")

        fetchCalendar()
    }

    // MARK: - Table view data source

    @objc func fetchCalendar() {
        groupedCalendars = CalendarGroup.fetch()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedCalendars.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedCalendars[section].list.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedCalendars[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = calendar.title
        cell.textLabel?.textColor = Colors.calendar(for: calendar)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]
        didSelect?(calendar)
        navigationController?.popViewController(animated: true)
    }

}
