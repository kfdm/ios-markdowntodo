//
//  CalendarView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/07.
//
// Taken from https://gist.github.com/mecid/f8859ea4bdbd02cf5d440d58e936faec

import SwiftUI

extension DateFormatter {
    fileprivate static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    fileprivate static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

extension Calendar {
    fileprivate func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

struct WeekView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let week: Date
    let content: (Date) -> DateView
    @Binding var selectedDate: Date

    init(week: Date, selectedDate: Binding<Date>, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.week = week
        self._selectedDate = selectedDate
        self.content = content
    }

    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        HStack {
            ForEach(days, id: \.self) { date in
                HStack {
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.content(date)
                            .onAppear(perform: {
                                self.updateDate(date: date)
                            })
                    } else {
                        self.content(date).hidden()
                    }
                }
            }
        }
    }

    private func updateDate(date: Date) {
        self.selectedDate = date
    }
}

struct MonthView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let month: Date
    let showHeader: Bool
    let content: (Date) -> DateView
    @Binding var selectedDate: Date

    init(
        month: Date,
        showHeader: Bool = true,
        selectedDate: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.month = month
        self.content = content
        self._selectedDate = selectedDate
        self.showHeader = showHeader
    }

    private var weeks: [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
        )
    }

    private var header: some View {
        let component = calendar.component(.month, from: month)
        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
        return Text(formatter.string(from: month))
            .font(.title)
            .padding()
    }

    var body: some View {
        VStack {
            if showHeader {
                header
            }

            ForEach(weeks, id: \.self) { week in
                WeekView(week: week, selectedDate: $selectedDate, content: self.content)
            }
        }
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let interval: DateInterval
    let content: (Date) -> DateView
    @Binding var selectedDate: Date

    init(interval: DateInterval, selectedDate: Binding<Date>, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.content = content
        self._selectedDate = selectedDate
    }

    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(months, id: \.self) { month in
                    MonthView(month: month, selectedDate: $selectedDate, content: self.content)
                }
            }
        }
    }
}
