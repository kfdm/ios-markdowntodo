//
//  Priorities.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

enum Priority: Int {
    typealias RawValue = Int

    case Unset = 0
    case Low = 4
    case Medium = 6
    case High = 8

    static func convert(rawValue: Int) -> Priority {
        switch rawValue {
        case 0:
            return .Unset
        case 1...5:
            return .Low
        case 6...7:
            return .Medium
        case 8...10:
            return .High
        default:
            print("Unknown Priority \(rawValue)")
            return .Unset
        }
    }
}
