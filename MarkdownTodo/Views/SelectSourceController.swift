//
//  SelectSourceController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/14.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class SelectSourceController: UITableViewController {
    var sources: [EKSource]!
    var selectedSource: ((EKSource) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Select Server", comment: "Select Calendar Server")
        sources = CalendarAPI.shared.sources
            .sorted { $0.title < $1.title }

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = sources[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSource?(sources[indexPath.row])
    }

}
