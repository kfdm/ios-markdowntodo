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
        PredicateView(predicate: eventStore.todayReminders())
            .navigationBarTitle("Upcoming")
    }
}

struct OverdueView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        PredicateView(predicate: eventStore.overdueReminders())
            .navigationBarTitle("Overdue")
    }
}

struct PlannerView: View {
    @Environment(\.calendar) var calendar

    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date())!
    }

    var body: some View {
        List {
            CalendarView(interval: month) { date in
                Text(String(self.calendar.component(.day, from: date)))
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(Circle())
                    .padding(.vertical, 4)
            }
            NavigationLink("Overdue", destination: OverdueView())
            NavigationLink("Upcoming", destination: UpcomingView())
        }
        .listStyle(GroupedListStyle())
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}
