//
//  EKCalendarEditView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/16.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct EKCalendarEditView: View {
    @Binding var calendar: EKCalendar
    var body: some View {
        List {
            TextField("Title", text: $calendar.title)
            ColorPicker("Color", selection: $calendar.cgColor)
        }
        .navigationBarTitle("Editing Calendar \(calendar.title)")
    }
}

struct EditCalendarButton: View {
    @State var calendar: EKCalendar

    @State private var isPresenting = false
    @EnvironmentObject var eventStore: LegacyEventStore

    var body: some View {
        Button("Edit", action: actionShowEdit)
            .sheet(isPresented: $isPresenting) {
                NavigationView {
                    EKCalendarEditView(calendar: $calendar)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel", action: actionShowEdit)
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save", action: actionSave)
                            }
                        }
                }
            }
    }

    func actionShowEdit() {
        isPresenting.toggle()
        calendar.reset()
    }

    func actionSave() {
        isPresenting.toggle()
        eventStore.save(calendar)
    }
}

struct EKCalendarEditView_Previews: PreviewProvider {
    static var previews: some View {
        EKCalendarEditView(calendar: .constant(EKCalendar()))
    }
}
