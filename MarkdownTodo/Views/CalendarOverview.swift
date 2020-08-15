//
//  CalendarOverview.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/15.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct DateIndicator: View {
    var reminders : [EKReminder]
    var body: some View {
        Group {
            switch reminders.count {
            case 0:
                Text(" ")
            case 1...3:
                Text(String(repeating: ".", count: reminders.count))
            default:
                Text("....")
            }
        }
        .font(.caption)
    }
}

struct CalendarOverview: View {
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }
    
    @Environment(\.calendar) var calendar
    @State var selectedDate = Date()
    
    // Query
    @EnvironmentObject var eventStore: EventStore
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var reminders: [Date: [EKReminder]] = [:]
    
    var body: some View {
        CalendarView(interval: month) { date in
            NavigationLink(
                destination: SelectedDateView(date: date).onAppear { selectedDate = date }
            ) {
                VStack {
                    Text(String(self.calendar.component(.day, from: date)))
                        .frame(width: 40, height: 40, alignment: .center)
                        .modifier(CalendarDateModifier(selectedDate: $selectedDate, date: date))
                        .clipShape(Circle())
                    DateIndicator(reminders: reminders[date] ?? [])
                }.padding(.vertical, 4)
            }
        }.onAppear(perform: fetch)
    }
    
    func fetch() {
        self.eventStore.publisher(for: eventStore.reminders(for: month))
            .receive(on: DispatchQueue.main)
            .map { $0.byDueDate() }
            .assign(to: \.reminders, on: self)
            .store(in: &self.subscriptions)
    }
}
