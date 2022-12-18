//
//  PriorityPicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import SwiftUI

struct PriorityPicker: View {
    var label: String
    @Binding var priority: Int

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: $priority) {
                ForEach(0..<10) { p in
                    Text("\(p)").tag(p)
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct PriorityPicker_Previews: PreviewProvider {
    static var previews: some View {
        PriorityPicker(label: "Test", priority: .constant(0))
    }
}
