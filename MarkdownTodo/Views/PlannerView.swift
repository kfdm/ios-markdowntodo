//
//  PlannerView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Combine
import EventKit
import SwiftUI

struct UpcomingView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateFetcher(predicate: eventStore.upcomingReminders(days: 7))
            .navigationBarTitle("Upcoming")
    }
}

struct TodayView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateFetcher(predicate: eventStore.overdueReminders())
            .navigationBarTitle("Today")
    }
}

struct CompletedView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateFetcher(predicate: eventStore.completeReminders())
            .navigationBarTitle("Completed")
    }
}

struct SelectedDateView: View {
    @EnvironmentObject var eventStore: EventStore

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    var date: Date
    var body: some View {
        PredicateFetcher(predicate: eventStore.reminders(for: date))
            .navigationBarTitle(formatter.string(from: date))
    }
}

struct PlannerView: View {
    @Environment(\.calendar) var calendar

    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }

    @State var selectedDate = Date()

    var body: some View {
        List {
            CalendarView(interval: month) { date in
                NavigationLink(
                    destination: SelectedDateView(date: date).onAppear { selectedDate = date }
                ) {
                    Text(String(self.calendar.component(.day, from: date)))
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(.vertical, 4)
                        .modifier(CalendarDateModifier(selectedDate: $selectedDate, date: date))
                        .clipShape(Circle())
                }
            }
            NavigationLink("Today", destination: TodayView())
            NavigationLink("Upcoming", destination: UpcomingView())
            NavigationLink("Completed", destination: CompletedView())
        }
        .listStyle(GroupedListStyle())
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
