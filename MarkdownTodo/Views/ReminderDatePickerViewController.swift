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

    var currentReminder: EKReminder? {
        didSet {
            print("\(currentReminder?.sortableDate)")
        }
    }
    @IBOutlet weak var calendarPicker: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        calendarPicker.select(currentReminder?.dueDateComponents?.date)
    }

    @objc func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func setToday(_ sender: UIButton) {
        currentReminder?.dueDateComponents = DateComponents.setToday()
        delegate?.saveReminder(reminder: currentReminder!)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func setUnscheduled(_ sender: UIButton) {
        currentReminder?.dueDateComponents = nil
        delegate?.saveReminder(reminder: currentReminder!)
        dismiss(animated: true, completion: nil)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentReminder?.dueDateComponents = DateComponents.setDue(to: date)
        delegate?.saveReminder(reminder: currentReminder!)
        dismiss(animated: true, completion: nil)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarManager.shared.numberOfEventsFor(date)
    }
}
