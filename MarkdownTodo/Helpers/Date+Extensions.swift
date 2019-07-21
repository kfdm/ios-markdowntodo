//
//  Date+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

extension Date {
    var midnight: Date {
        get {
            return Calendar.current.startOfDay(for: self)
        }
    }
    var tomorrow: Date {
        get {
            return Calendar.current.date(byAdding: .day, value: 1, to: self)!
        }
    }
}
