//
//  SettingsViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/07.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case [0, 1]:
            UIApplication.shared.open(URL(string: "https://github.com/kfdm/ios-markdowntodo")!)
        default:
            print("Unknown index path \(indexPath)")
        }
    }
}
