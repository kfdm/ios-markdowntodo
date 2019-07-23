//
//  DateViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import FSCalendar

class DateViewCell: UITableViewCell, FSCalendarDelegate, FSCalendarDataSource {
    @IBOutlet private weak var labelField: UILabel!
    @IBOutlet private weak var valueField: UILabel!
    @IBOutlet private weak var segmentField: UISegmentedControl!
    @IBOutlet weak var datePicker: FSCalendar!

    var changed: ((DateComponents?) -> Void)?
    var date: DateComponents?

    var label: String {
        get {
            return labelField.text ?? ""
        }
        set {
            labelField.text = newValue
        }
    }

    @IBAction func selectionDate(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            datePicker.select(Date(), scrollToDate: true)
            dateSet(Date())
        case 1:
            datePicker.select(Date().tomorrow, scrollToDate: true)
            dateSet(Date().tomorrow)
        case 2:
            datePicker.clearAllSelections()
            dateSet(nil)
        default:
            print("unknown")
        }
    }

    func dateSet(_ newDate: Date?) {
        if let checkedDate = newDate {
            let calendar = Calendar.current
            date = calendar.dateComponents([.year, .month, .day], from: checkedDate)
            valueField.text = Formats.full(checkedDate)
            changed?(date)
        } else {
            valueField.text = Labels.unscheduled
            changed?(nil)
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        segmentField.selectedSegmentIndex = 3
        dateSet(date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarManager.shared.numberOfEventsFor(date)
    }
}
