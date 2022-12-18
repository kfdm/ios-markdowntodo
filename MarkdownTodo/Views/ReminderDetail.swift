//
//  ReminderDetail.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import EventKit
import SwiftUI

struct ReminderDetail: View {
    @EnvironmentObject var store: MarkdownEventStore
    @State var reminder: EKReminder
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        EKReminderEditView(reminder: $reminder)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveAction)
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", action: deleteAction)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(reminder.title)
            .navigationBarBackButtonHidden(true)
    }

    func saveAction() {
        store.save(reminder)
        presentationMode.wrappedValue.dismiss()
    }

    func cancelAction() {
        reminder.reset()
        presentationMode.wrappedValue.dismiss()
    }

    func deleteAction() {
        store.remove(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}
