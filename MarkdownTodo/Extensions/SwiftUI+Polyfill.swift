//
//  SwiftUI+Polyfill.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/11.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct Link: View {
    var label: String
    var destination: URL

    var body: some View {
        Button(action: openLink) {
            Text(label)
        }
    }
    func openLink() {
        UIApplication.shared.open(destination)
    }
}

extension Link {
    init(_ label: String, destination: URL) {
        self.label = label
        self.destination = destination
    }
}
