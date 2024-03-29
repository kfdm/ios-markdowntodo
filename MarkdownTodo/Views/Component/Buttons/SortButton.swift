//
//  SortButton.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/08.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

enum SortOptions: String, CaseIterable {
    case dueDate = "Due Date"
    case createdDate = "Created Date"
    case priority
    case title
    case agenda
    case calendar
}

struct SortButton: View {
    @Binding var sortBy: SortOptions

    @State private var showSortMenu = false

    var body: some View {
        Button(action: { showSortMenu = true }) {
            Image(systemName: "arrow.up.arrow.down")
        }
        .sheet(isPresented: $showSortMenu) {
            NavigationView {
                List {
                    ForEach(SortOptions.allCases, id: \.rawValue) { sortMethod in
                        Button(sortMethod.rawValue.capitalized) {
                            sortBy = sortMethod
                            showSortMenu = false
                        }.foregroundColor(sortBy == sortMethod ? .accentColor : .primary)
                    }
                }
                .navigationBarTitle("Sort By", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: { showSortMenu = false })
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
