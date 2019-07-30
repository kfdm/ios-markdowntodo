//
//  Shortcuts.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class Labels {
    static var unscheduled = NSLocalizedString("Unscheduled", comment: "Currently Unscheduled")
}

class Images {
    static var statusDone = UIImage(named: "statusDone")
    static var statusOverdue = UIImage(named: "statusOverdue")
    static var statusEmpty = UIImage(named: "statusEmpty")
    static var link = UIImage(named: "link")
}

class Formats {
    static func short(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    static func full(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
