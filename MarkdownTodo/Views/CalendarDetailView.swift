//
//  CalendarView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

// Test out answer from https://stackoverflow.com/a/58427754/622650
struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>)
        -> UIViewController
    {
        UIViewController()
    }
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct CalendarDetailView: View {
    @EnvironmentObject var eventStore: EventStore
    var calendar: EKCalendar

    // Query
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [EKReminder] = []

    var body: some View {
        List {
            ForEach(reminders) { reminder in
                NavigationLink(destination: ReminderDetail(reminder: reminder)) {
                    ReminderRow(reminder: reminder)
                }
            }
        }
        .onAppear {
            self.eventStore.reminders(for: self.calendar)
                .receive(on: DispatchQueue.main)
                .assign(to: \.reminders, on: self)
                .store(in: &self.subscriptions)
        }
        .navigationBarTitle(calendar.title)
        .background(
            NavigationConfigurator { nc in
                nc.navigationBar.barTintColor = UIColor(cgColor: self.calendar.cgColor)
            })
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDetailView(calendar: EKCalendar())
    }
}
