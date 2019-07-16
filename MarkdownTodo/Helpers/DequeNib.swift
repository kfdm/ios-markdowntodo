//
//  Nibbable.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

extension UITableView {
    func registerReusableCell<T: UITableViewCell>(tableViewCell: T.Type) {
        let fullName = NSStringFromClass(T.self)
        let className = fullName.components(separatedBy: ".")[1]
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    func dequeueReusableCell<T: UITableViewCell>(withIdentifier: T.Type) -> T {
        let fullName = NSStringFromClass(withIdentifier)
        let className = fullName.components(separatedBy: ".")[1]
        return dequeueReusableCell(withIdentifier: className) as! T
    }
}
