//
//  MasterViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit

class CalendarListViewController: UIViewController {

    var detailViewController: ReminderListViewController?
    private var groupedCalendars = GroupedCalendarBySource()

    @IBOutlet weak private var tableView: UITableView!

    @objc func fetchCalendar() {
        CalendarManager.shared.authenticated(completionHandler: {
            self.groupedCalendars = GroupedCalendarBySource()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchCalendar), for: .valueChanged)

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderListViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCalendar()
    }

    func showReminderController(_ completionHandler: (ReminderListViewController) -> Void) {
        let controller = ReminderListViewController.instantiate()
        let nav = UINavigationController(rootViewController: controller)
        completionHandler(controller)
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        splitViewController?.showDetailViewController(nav, sender: self)
    }

    @IBAction func clickToday(_ sender: Any) {
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let pred = CalendarManager.shared.store.predicateForIncompleteReminders(withDueDateStarting: Date.distantPast, ending: date, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Today"
            controller.selectedCalendar = nil
            controller.selectedPredicate = pred
            controller.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        }
    }
    @IBAction func clickUpcoming(_ sender: UIButton) {
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let pred = CalendarManager.shared.store.predicateForIncompleteReminders(withDueDateStarting: date, ending: Date.distantFuture, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Upcoming"
            controller.selectedCalendar = nil
            controller.selectedPredicate = pred
            controller.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        }
    }

    @IBAction func clickSettingsButton(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @IBAction func clickAboutButton(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: "https://github.com/kfdm/ios-markdowntodo")!)
    }
}

// MARK: - UITableViewDataSource
extension CalendarListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedCalendars.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedCalendars.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let calendar = groupedCalendars.cellForRowAt(indexPath)

        cell.textLabel!.text = calendar.title
        cell.textLabel?.textColor = Colors.calendar(for: calendar)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedCalendars.titleForHeader(section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = groupedCalendars.cellForRowAt(indexPath)
        let predicate = CalendarManager.shared.predicateForReminders(in: calendar)
        showReminderController { (controller) in
            controller.title = calendar.title
            controller.navigationController?.navigationBar.barTintColor = Colors.calendar(for: calendar)
            controller.selectedPredicate = predicate
            controller.selectedCalendar = calendar
        }
    }
}
