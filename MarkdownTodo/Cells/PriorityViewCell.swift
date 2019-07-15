//
//  PriorityViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

enum Options: Int {
    typealias RawValue = Int

    case Unset = 0
    case Low = 1
    case Medium = 2
    case High = 3
}

class PriorityViewCell: UITableViewCell {
    @IBOutlet weak var selectorPriority: UISegmentedControl!

    static func create(_ tableView: UITableView, for reminder: EKReminder) -> PriorityViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "Priority") as! PriorityViewCell
        cell.setPriority(for: reminder)
        return cell
    }

    static func getPriority(for sender: UISegmentedControl) -> Int {
        switch Options.init(rawValue: sender.selectedSegmentIndex)! {
        case .Unset:
            return Priority.Unset.rawValue
        case .Low:
            return Priority.Low.rawValue
        case .Medium:
            return Priority.Med.rawValue
        case .High:
            return Priority.High.rawValue
        }
    }

    func setPriority(for reminder: EKReminder) {
        switch Priority.init(rawValue: reminder.priority)! {
        case .Unset:
            selectorPriority.selectedSegmentIndex = Options.Unset.rawValue
        case .Low:
            selectorPriority.selectedSegmentIndex = Options.Low.rawValue
        case .Med:
            selectorPriority.selectedSegmentIndex = Options.Medium.rawValue
        case .High:
            selectorPriority.selectedSegmentIndex = Options.High.rawValue
        }
    }
}
