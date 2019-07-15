//
//  Priorities.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

enum Priority : Int {
    typealias RawValue = Int
    
    case Unset = 0
    case Low = 2
    case Med = 6
    case High = 8

    static func convert(from: Int) -> Priority {
        switch from {
        case 0:
            return .Unset
        case 1...5:
            return .Low
        case 6:
            return .Med
        case 8:
            return .High
        default:
            print("Unknown Priority \(from)")
            return .Unset
        }
    }
}
