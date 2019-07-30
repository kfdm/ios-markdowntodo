//
//  ReminderGroup.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/23.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

protocol ReminderGroup {
    var title: String { get }
    var events: [EKReminder] { get }
}
