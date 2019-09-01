//
//  DatePickerViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit
import FSCalendar

class DatePickerViewController: UITableViewController, FSCalendarDelegate, FSCalendarDataSource, Storyboarded {
    var currentDate: DateComponents?
    var didSelect: ((DateComponents?) -> Void)? {
        didSet {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        }
    }

    var didCancel: (() -> Void)? {
        didSet {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DateViewCell.self)
    }

    @objc func saveEdit() {
        didSelect?(currentDate)
    }

    @objc func cancelEdit() {
        didCancel?()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DateViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.label = NSLocalizedString("Due", comment: "Due Date")
        cell.value = currentDate
        cell.changed = { self.currentDate = $0 }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = DateComponents.setDue(to: date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarAPI.shared.numberOfEventsFor(date)
    }
}
