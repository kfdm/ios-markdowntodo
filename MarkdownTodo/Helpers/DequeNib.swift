//
//  Nibbable.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

protocol DequeNib {
    static func register(_ tableView: UITableView)
    static func dequeueReusableCell(_ tableView: UITableView) -> Self
}

extension DequeNib where Self: UITableViewCell {
    static func register(_ tableView: UITableView) {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let nib = UINib(nibName: className, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: className)
    }

    static func dequeueReusableCell(_ tableView: UITableView) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        return tableView.dequeueReusableCell(withIdentifier: className) as! Self
    }
}
