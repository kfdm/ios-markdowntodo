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
    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var valueField: UILabel!

    var date : DateComponents? {
        didSet {
            valueField.text = "\(date)"
        }
    }

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
            let newDate = Date()
            let calendar = Calendar.current
            date = calendar.dateComponents([.year, .month, .day], from: newDate)
        case 1:
            let newDate = Date().tomorrow
            let calendar = Calendar.current
            date = calendar.dateComponents([.year, .month, .day], from: newDate)
        case 2:
            date = nil
        default:
            print("unknown")
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let calendar = Calendar.current
        self.date = calendar.dateComponents([.year, .month, .day], from: date)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarManager.shared.numberOfEventsFor(date)
    }
}
