//
//  MasterViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class CalendarListViewController: UITableViewController {
    private var groupedCalendars = [CalendarGroup]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchCalendar), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(fetchCalendar), name: .authenticationGranted, object: nil)
        navigationItem.leftBarButtonItem = editButtonItem
    }

    @IBAction func showAddCalendar(_ sender: UIBarButtonItem) {
        let vc = NewCalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CalendarAPI.shared.authenticated(completionHandler: {
            print("Authentication Granted")
        })
    }

    func showReminderController(_ completionHandler: (ReminderListViewController) -> Void) {
        let controller = ReminderListViewController.instantiate()
        let nav = UINavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        completionHandler(controller)
        splitViewController?.showDetailViewController(nav, sender: self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedCalendars.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedCalendars[section].list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]

        cell.textLabel!.text = calendar.title
        cell.textLabel?.textColor = Colors.calendar(for: calendar)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedCalendars[section].title
    }

    func didOpenCalendarAt(_ calendar: EKCalendar) {
        let predicate = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [calendar])
        showReminderController { (controller) in
            controller.title = calendar.title
            controller.navigationController?.navigationBar.isTranslucent = false
            controller.navigationController?.navigationBar.barTintColor = Colors.calendar(for: calendar)
            controller.selectedPredicate = predicate
            controller.selectedCalendars = [calendar]
        }
    }

    func didEditCalendarAt(_ calendar: EKCalendar) {
        let vc = EditCalendarViewController(for: calendar)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]
        if tableView.isEditing {
            didEditCalendarAt(calendar)
        } else {
            didOpenCalendarAt(calendar)
        }
    }

    @objc func fetchCalendar() {
        groupedCalendars = CalendarGroup.fetch()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

struct CalendarGroup {
    let title: String
    let list: [EKCalendar]
}

extension CalendarGroup {
    static func fetch() -> [CalendarGroup] {
        let sorted = CalendarAPI.shared.calendars.sorted { $0.cgColor.hashValue > $1.cgColor.hashValue }
        // TODO Figure out why grouping by EKSource doesn't work anymore
        return Dictionary(grouping: sorted) { $0.source.title }
            .map { CalendarGroup(title: $0, list: $1 )}
            .sorted { $0.title < $1.title }
    }
}
