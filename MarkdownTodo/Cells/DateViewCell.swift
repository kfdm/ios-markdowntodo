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
    
    var changed : ((DateComponents?) -> Void)?
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
        case 1:
            datePicker.select(Date().tomorrow, scrollToDate: true)
        case 2:
            datePicker.clearAllSelections()
            date = nil
            changed?(nil)
        default:
            print("unknown")
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        segmentField.selectedSegmentIndex = 3
        let calendar = Calendar.current
        self.date = calendar.dateComponents([.year, .month, .day], from: date)
        changed?(self.date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarManager.shared.numberOfEventsFor(date)
    }
}
