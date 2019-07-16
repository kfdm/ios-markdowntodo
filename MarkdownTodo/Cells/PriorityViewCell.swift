//
//  PriorityViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit


class PriorityViewCell: UITableViewCell {
    @IBOutlet weak var selectorPriority: UISegmentedControl!

    override func awakeFromNib() {
        selectorPriority.removeAllSegments()
        for i in 0...9 {
            selectorPriority.insertSegment(withTitle: "\(i)", at: i, animated: false)
        }
    }

    static func getPriority(for sender: UISegmentedControl) -> Int {
        return sender.selectedSegmentIndex
    }

    func setPriority(for reminder: EKReminder) {
        selectorPriority.selectedSegmentIndex = reminder.priority
    }
}
