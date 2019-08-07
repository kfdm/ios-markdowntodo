//
//  UITableView+ReusableCell.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/15.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

protocol ReusableCell {
    static var defaultResueIdentifier: String { get }
    static var nibName: String { get }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableCell {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.defaultResueIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultResueIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell \(T.defaultResueIdentifier)")
        }
        return cell
    }
}

extension ReusableCell {
    static var defaultResueIdentifier: String {
        return String(describing: self)
    }
    static var nibName: String {
        return String(describing: self)
    }
}
