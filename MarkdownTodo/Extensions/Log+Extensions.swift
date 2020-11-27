//
//  Log+Extensions.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/11/27.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    static var predicate = OSLog.init(
        subsystem: Bundle.main.bundleIdentifier!, category: "Predicate")
    static var event = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "EventStore")
}
