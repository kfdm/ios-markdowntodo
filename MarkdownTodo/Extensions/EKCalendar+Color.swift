//
//  EKCalendar+Color.swift
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
