//
//  ListView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct ListView: View {
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
                                Text(calendar.title)
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
        ListView()
    }
}
