//
//  TextViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import WebKit
import EventKit
import Down

class MarkdownViewCell: UITableViewCell, UITextViewDelegate, ReusableCell {
    @IBOutlet private weak var labelField: UILabel!
    @IBOutlet private weak var textField: UITextView!
    @IBOutlet private weak var previewSwitch: UISwitch!
    @IBOutlet private weak var webView: WKWebView!

    var changed: ((String) -> Void)?

    var label: String {
        get {
            return labelField.text!
        }
        set {
            labelField.text = newValue
        }
    }

    var value: String {
        get {
            return textField.text!
        }
        set {
            textField.text = newValue
        }
    }

    @IBAction func togglePreview(_ sender: UISwitch) {
        webView.isHidden = !sender.isOn
        textField.isHidden = sender.isOn

        if sender.isOn {
            let down = Down(markdownString: textField.text)
            webView.loadHTMLString(try! down.toHTML(), baseURL: nil)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        changed?(textField.text)
    }

}
