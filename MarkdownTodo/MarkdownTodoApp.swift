//
//  MarkdownTodoApp.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

@main
struct MarkdownTodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MarkdownEventStore.shared)
        }
    }
}
