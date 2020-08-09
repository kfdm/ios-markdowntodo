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
    @Binding var dateComponent: DateComponents?

    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @Environment(\.calendar) var calendar

    func showSheet() {
        showDatePicker = true
        selectedDate = dateComponent?.date ?? Date()
    }

    func clickCancel() {
        showDatePicker = false
    }

    func clickSave() {
        dateComponent = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute], from: selectedDate)
        showDatePicker = false
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: showSheet) {
                DateView(date: dateComponent, whenUnset: "Unscheduled")
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationView {
                    HStack {
                        DatePicker(selection: $selectedDate, displayedComponents: .date) {
                            Text("Select Date")
                        }
                        DatePicker(selection: $selectedDate, displayedComponents: .hourAndMinute) {
                            Text("Select Time")
                        }
                        Button("Clear", action: clickClear).buttonStyle(DestructiveButtonStyle())
                    }
                    .navigationBarTitle("Date Picker", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Cancel", action: clickCancel),
                        trailing: Button("Save", action: clickSave)
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

struct DateTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        DateTimePicker(label: "Preview", dateComponent: .constant(DateComponents()))
    }
}
