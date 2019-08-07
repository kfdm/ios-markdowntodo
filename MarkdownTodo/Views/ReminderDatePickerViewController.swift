//
//  ReminderDatePickerViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit
import FSCalendar

class ReminderDatePickerViewController: UITableViewController, FSCalendarDelegate, FSCalendarDataSource, Storyboarded {
    weak var delegate: ReminderActions?
    var currentReminder: EKReminder?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(DateViewCell.self)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        navigationItem.leftItemsSupplementBackButton = true
    }

    @objc func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveEdit() {
        guard let reminder = currentReminder else { return }
        CalendarAPI.shared.save(reminder: reminder, commit: true)
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DateViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.label = NSLocalizedString("Due", comment: "Due Date")
        cell.date = currentReminder?.dueDateComponents
        cell.changed = { newDate in self.currentReminder?.dueDateComponents = newDate }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 256
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let reminder = currentReminder else { return }
        reminder.dueDateComponents = DateComponents.setDue(to: date)
        CalendarAPI.shared.save(reminder: reminder, commit: true)
        dismiss(animated: true, completion: nil)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarAPI.shared.numberOfEventsFor(date)
    }
}
