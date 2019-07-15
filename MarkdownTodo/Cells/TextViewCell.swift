//
//  TextViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell, DequeNib {
    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var textField: UITextView!
}
