//
//  MasterViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import EventKit
import FSCalendar

class CalendarListViewController: UIViewController {

    var detailViewController: ReminderListViewController?
    private var groupedCalendars = [CalendarGroup]()

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var calendarPicker: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchCalendar), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(fetchCalendar), name: .authenticationGranted, object: nil)

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderListViewController
        }
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
        completionHandler(controller)
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
        splitViewController?.showDetailViewController(nav, sender: self)
    }

    // MARK: - IBAction

    @IBAction func clickSettingsButton(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @IBAction func clickAboutButton(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: "https://github.com/kfdm/ios-markdowntodo")!)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedCalendars.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedCalendars[section].list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]

        cell.textLabel!.text = calendar.title
        cell.textLabel?.textColor = Colors.calendar(for: calendar)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedCalendars[section].title
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = groupedCalendars[indexPath.section].list[indexPath.row]
        let predicate = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [calendar])
        showReminderController { (controller) in
            controller.title = calendar.title
            controller.navigationController?.navigationBar.barTintColor = Colors.calendar(for: calendar)
            controller.selectedPredicate = predicate
            controller.selectedCalendars = [calendar]
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
