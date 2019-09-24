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
    @IBOutlet private weak var markdownPreview: WKWebView!

    var changed: ((String) -> Void)?

    var value: String? {
        didSet {
            textField.text = value
//            textField.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    override func awakeFromNib() {
        markdownPreview.navigationDelegate = self
    }

    @IBAction func togglePreview(_ sender: UISwitch) {
        markdownPreview.isHidden = !sender.isOn
        textField.isHidden = sender.isOn

        if sender.isOn {
            let down = Down(markdownString: textField.text)
            guard let body = try? down.toHTML() else { return }
            let html = """
<html>
<head>
    <style>
            body { color: blue; }
    </style>
</head>
<body>
\(body)
</body>
</html>
"""
            markdownPreview.loadHTMLString(html, baseURL: nil)
        }

    }

    func textViewDidChange(_ textView: UITextView) {
        changed?(textField.text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        textField.becomeFirstResponder()
    }

}

extension MarkdownViewCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
        }
    }
}
