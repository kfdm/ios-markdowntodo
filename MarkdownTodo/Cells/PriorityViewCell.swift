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
    var changed: ((Int) -> Void)?

    var priority: Int {
        get {
            return selectorPriority.selectedSegmentIndex
        }
        set {
            selectorPriority.selectedSegmentIndex = newValue
        }
    }

    override func awakeFromNib() {
        selectorPriority.removeAllSegments()
        selectorPriority.addTarget(self, action: #selector(updatedPriority), for: .valueChanged)
        for i in 0...9 {
            selectorPriority.insertSegment(withTitle: "\(i)", at: i, animated: false)
        }
    }

    @objc func updatedPriority() {
        changed?(selectorPriority.selectedSegmentIndex)
    }
}
