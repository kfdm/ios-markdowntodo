//
//  Date+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation

extension Date {
    var midnight: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
    }
}
