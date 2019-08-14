//
//  StringViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class StringViewCell: UITableViewCell, ReusableCell {
    @IBOutlet private weak var
    labelField: UILabel!
    @IBOutlet private weak var textField: UITextField!

    var textChanged: ((String) -> Void)?

    var label: String? {
        get {
            return labelField.text
        }
        set {
            labelField.text = newValue
        }
    }

    var value: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    override func awakeFromNib() {
        textField.addTarget(self, action: #selector(updatedText), for: .valueChanged)
        textField.addTarget(self, action: #selector(updatedText), for: .editingDidEnd)
    }

    @objc func updatedText() {
        textChanged?(textField!.text!)
    }
}
