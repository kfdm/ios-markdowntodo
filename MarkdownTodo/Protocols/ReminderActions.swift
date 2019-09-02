//
//  ReminderActions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

protocol ReminderActions: class {
    func showPriorityDialog(reminder: EKReminder)
    func showScheduleDialog(reminder: EKReminder)
    func showStatusDialog(reminder: EKReminder)
    func showList(reminder: EKReminder)
}
