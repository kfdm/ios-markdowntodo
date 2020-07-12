//
//  MarkdownView.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2020/07/12.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI
import UIKit

struct MarkdownView: View {
    var label: String
    @Binding var text: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            MarkdownSub(text: $text)
                .frame(width: nil, height: 128, alignment: .topLeading)
        }
    }
}

struct MarkdownSub: UIViewRepresentable {
    @Binding var text: String?

    func makeUIView(context: Context) -> UITextView {
        return UITextView()
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView(label: "Test", text: .constant("Some description"))
    }
}
