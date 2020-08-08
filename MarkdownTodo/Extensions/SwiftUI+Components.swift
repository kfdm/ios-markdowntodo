//
//  SwiftUI+Components.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct NameValue: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}

struct NameField: View {
    var label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, text: $value)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct DateView: View {
    var date: Date
    var whenUnset = "Unset"
    var formatter = DateFormatter.dateAndTime

    var body: some View {
        if date.isSentinel {
            Text(whenUnset)
        } else {
            Text(formatter.string(from: date))
        }
    }
}

extension DateView {
    init(date from: DateComponents?, whenUnset: String = "Unset") {
        date = from?.date ?? Date.distantFuture
        self.whenUnset = whenUnset
    }
}
