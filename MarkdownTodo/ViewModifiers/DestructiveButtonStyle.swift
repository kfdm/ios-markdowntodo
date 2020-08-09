//
//  DestructiveButtonStyle.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/08/09.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.foregroundColor(.red)
    }
}
