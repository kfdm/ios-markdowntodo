//
//  LinkField.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2021/01/14.
//  Copyright © 2021 Paul Traylor. All rights reserved.
//

import SwiftUI

struct LinkField: View {
    @Binding var url: URL?
    @State private var text = ""

    var body: some View {
        TextField("URL", text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
            .keyboardType(.URL)
    }

    func onCommit() {
        url = URL(string: text)
    }
    func onEditingChanged(_ commit: Bool) {
        url = URL(string: text)
    }

    init(url: Binding<URL?>) {
        self._url = url
        self._text = .init(wrappedValue: url.wrappedValue?.absoluteString ?? "")
    }
}

struct LinkField_Previews: PreviewProvider {
    static var previews: some View {
        LinkField(url: .constant(URL(string: "http://example.com")))
    }
}
