//
//  SimpleTableViewCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/14.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class SimpleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
