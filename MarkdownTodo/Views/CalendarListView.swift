//
//  ListView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct CalendarListView: View {
    @EnvironmentObject var eventStore: EventStore

    var body: some View {
        Group {
            if eventStore.authorized {
                List {
                    ForEach(eventStore.sources, id: \.sourceIdentifier) { (source) in
                        Section(header: Text(source.title)) {
                            ForEach(
                                self.eventStore.calendars(for: source), id: \.calendarIdentifier
                            ) { (calendar) in
                                NavigationLink(destination: CalendarDetailView(calendar: calendar))
                                {
                                    Text(calendar.title)
                                        .foregroundColor(calendar.color)
                                }
                            }
                        }
                    }
                }.listStyle(GroupedListStyle())
            } else {
                Text("Not authed")
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarListView()
    }
}
