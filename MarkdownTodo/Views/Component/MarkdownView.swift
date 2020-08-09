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

fileprivate struct MarkdownSub: UIViewRepresentable {

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownSub

        init(_ parent: MarkdownSub) {
            self.parent = parent
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }

    @Binding var text: String?

    func makeUIView(context: Context) -> UITextView {
        return UITextView()
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.delegate = context.coordinator
        uiView.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

}

struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownView(label: "Test", text: .constant("Some description"))
    }
}
