//
//  MarkdownView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/12.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Ink
import SwiftUI
import UIKit
import WebKit

struct MarkdownPreviewView: UIViewRepresentable {
    @Binding var text: String
    let parser = MarkdownParser()

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(parser.html(from: text), baseURL: nil)
    }
}

struct MarkdownView: View {
    var label: String
    @Binding var text: String
    @State private var showPreview = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Toggle("Show Preview", isOn: $showPreview)
            }
            if showPreview {
                MarkdownPreviewView(text: $text)
            } else {
                TextEditor(text: $text)
            }
        }
        .frame(minHeight: 256, alignment: .topLeading)
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView(label: "Test", text: .constant("Some description"))
    }
}
