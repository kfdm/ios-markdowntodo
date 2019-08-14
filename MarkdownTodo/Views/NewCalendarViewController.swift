//
//  NewCalendarViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/14.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class NewCalendarViewController: UITableViewController {
    private var name: String?
    private var source: EKSource?

    init() { super.init(style: .grouped) }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("New Calendar", comment: "Edit Reminder Title")

        tableView.register(StringViewCell.self)
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 44.0

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdit))
        navigationItem.leftItemsSupplementBackButton = true
    }

    @objc func cancelEdit() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveEdit() {
        guard let newName = name else { return }
        guard let newSource = source else { return }

        let calendar = CalendarAPI.shared.newCalendar(for: newSource)
        calendar.title = newName
        CalendarAPI.shared.save(calendar: calendar, commit: true)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: StringViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Name"
            cell.textChanged = { self.name = $0 }
            cell.selectionStyle = .none
            return cell
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Source"
            cell.detailTextLabel?.text = source?.title
            cell.accessoryType = .disclosureIndicator
            return cell
        case [0, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Color"
            return cell
        default:
            fatalError("Unknown cell for index \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 1]:
            let vc = SelectSourceController()
            vc.selectedSource = {
                self.source = $0
                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            print("No selection")
        }
    }
}
