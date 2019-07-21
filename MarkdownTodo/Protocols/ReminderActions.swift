//
//  ReminderActions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

protocol ReminderActions: class {
    func priorityFor(reminder: EKReminder)
    func scheduleFor(reminder: EKReminder)
}
