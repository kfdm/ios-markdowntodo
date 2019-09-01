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
        didSet {
            textField.placeholder = label
        }
    }

    var value: String? {
        didSet {
            textField.text = value
        }
    }

    var keyboardType: UIKeyboardType? {
        didSet {
            textField.keyboardType = keyboardType ?? UIKeyboardType.alphabet
        }
    }

    override func awakeFromNib() {
        textField.addTarget(self, action: #selector(updatedText), for: .editingChanged)
    }

    @objc func updatedText() {
        textChanged?(textField!.text!)
    }
}
