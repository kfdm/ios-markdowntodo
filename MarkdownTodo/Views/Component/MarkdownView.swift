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
    var html: String

    init(html: String) {
        self.html = html
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

struct MarkdownView: View {
    var label: String
    @Binding var text: String
    @State private var showPreview = true

    var html: String {
        let parser = MarkdownParser()
        return parser.html(from: $text.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Toggle("Preview", isOn: $showPreview)
            }
            HStack {
                TextEditor(text: $text)
                if showPreview {
                    MarkdownPreviewView(html: html)
                }
            }
        }
        .frame(minHeight: 256, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension String {
    func markdownToAttributed() -> AttributedString {
        do {
            return try AttributedString(markdown: self)
        } catch {
            return AttributedString("Error parsing")
        }
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView(label: "Test", text: .constant("Some description"))
    }
}
