//
//  DateTimePicker.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct DateTimePicker: View {
    var label: String
    @Binding var date: DateComponents?
    @State private var showDatePicker = false
    @State private var startDate = Date()

    func actionShow() {
        showDatePicker = true
        startDate = date?.date ?? Date()
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: { showDatePicker = true }) {
                DateView(date: date, whenUnset: "Unscheduled")
            }
            .sheet(isPresented: $showDatePicker) {
                Text("Date")
                    .font(.largeTitle)
                DatePicker(selection: $startDate, displayedComponents: .date) {
                    Text("Select Date")
                }
                DatePicker(selection: $startDate, displayedComponents: .hourAndMinute) {
                    Text("Select Time")
                }
            }
        }
    }
}

struct DateTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        DateTimePicker(label: "Preview", date: .constant(DateComponents()))
    }
}
