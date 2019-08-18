//
//  DateViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import FSCalendar

class DateViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource, ReusableCell {
    @IBOutlet private weak var labelField: UILabel!
    @IBOutlet private weak var valueField: UILabel!
    @IBOutlet private weak var datePicker: FSCalendar!

    var changed: ((DateComponents?) -> Void)?
    var value: DateComponents? {
        didSet {
            if let date = value?.date {
                valueField.text = Formats.full(date)
                datePicker.select(date, scrollToDate: true)
            } else {
                valueField.text = Labels.unscheduled
                datePicker.clearAllSelections()
            }
        }
    }

    var label: String? {
        didSet {
            labelField.text = label
        }
    }

    @IBAction func selectToday(_ sender: UIButton) {
        dateSet(Date())
    }

    @IBAction func selectTomorrow(_ sender: UIButton) {
        dateSet(Date().tomorrow)
    }

    @IBAction func selectUnschedule(_ sender: UIButton) {
        dateSet(nil)
    }

    func dateSet(_ newDate: Date?) {
        if let checkedDate = newDate {
            value = Calendar.current.dateComponents([.calendar, .year, .month, .day], from: checkedDate)
        } else {
            value = nil
        }
        changed?(value)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateSet(date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarAPI.shared.numberOfEventsFor(date)
    }
}
