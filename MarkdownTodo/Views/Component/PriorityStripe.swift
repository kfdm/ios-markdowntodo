//
//  PriorityStripe.swift
//  PriorityStripe
//
//  Created by Paul Traylor on 2021/07/29.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct PriorityStripe: View {
    let priority: Int
    let width = 8.0
    var color: Color {
        switch priority {
        case 1...2:
            return Color.red
        case 3...4:
            return Color.orange
        case 5...6:
            return Color.green
        case 7...9:
            return Color.blue
        default:
            return Color.gray
        }
    }
    var body: some View {
        color.frame(width: width)
    }
}
