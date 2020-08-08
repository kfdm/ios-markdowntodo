//
//  EventKit+SwiftUI.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

extension EKCalendar {
    var color: Color {
        Color(UIColor(cgColor: self.cgColor))
    }
}

extension EKReminder: Identifiable {
    public var id: String {
        return calendarItemIdentifier
    }
}

extension EKSource: Identifiable {
    public var id: String {
        return sourceIdentifier
    }
}

extension EKRecurrenceRule: Identifiable {
    public var id: String {
        return calendarIdentifier
    }
}
