//
//  Observers.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var savedReminder: Notification.Name {
        return .init(rawValue: "Reminder.Saved")
    }
    static var authenticationGranted: Notification.Name {
        return .init(rawValue: "Authentication.Granted")
    }
}
