//
//  MarkdownView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/12.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import MarkdownUI
import SwiftUI
import UIKit
import WebKit

struct MarkdownView: View {
    var label: String
    @Binding var text: String
    @State private var buffer = ""
    @State private var showPreview = true

    enum ViewMode {
        case both
        case edit
        case preview
    }

    @State private var mode = ViewMode.both

    var body: some View {
        VStack(alignment: .leading) {
            Picker(label, selection: $mode) {
                Text("Edit").tag(ViewMode.edit)
                Text("Both").tag(ViewMode.both)
                Text("Preview").tag(ViewMode.preview)
            }
            .pickerStyle(.segmented)
            HStack(alignment: .top) {
                if mode == .both || mode == .edit {
                    TextEditor(text: $buffer)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .border(.red)
                }
                if mode == .both || mode == .preview {
                    Markdown(buffer)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .border(.green)
                }
            }
        }
        // MARK: - Fixes for binding/state and markdown live preview
        .task {
            buffer = text
        }
        .onChange(of: buffer) { newValue in
            text = newValue
        }
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView(label: "Test", text: .constant("Some description"))
    }
}
