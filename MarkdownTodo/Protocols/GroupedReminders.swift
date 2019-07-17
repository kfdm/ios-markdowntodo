//
//  SortedReminders.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/17.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import EventKit

protocol GroupedReminders {
    var numberOfSections: Int { get }
    func titleForHeader(_ section: Int) -> String
    func numberOfRowsInSection(_ section: Int) -> Int
    func reminderForRowAt(_ indexPath: IndexPath) -> EKReminder
}
