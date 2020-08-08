//
//  EventKit+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit

extension EKReminder {
    var hasURL: Bool {
        return url != nil
    }

    var hasDueDate: Bool {
        return dueDateComponents != nil
    }

    var dueDate: Date {
        return dueDateComponents?.date ?? Date.distantFuture
    }
}
