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
    private var groupedCalendars = GroupedCalendarBySource()

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var calendarPicker: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchCalendar), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(calendarReloadData), name: .savedReminder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchCalendar), name: .authenticationGranted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(calendarReloadData), name: .authenticationGranted, object: nil)

//        calendarPicker.scrollDirection = .vertical
//        calendarPicker.scope = .week
        calendarPicker.appearance.headerMinimumDissolvedAlpha = 0.0

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderListViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CalendarManager.shared.authenticated(completionHandler: {
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

    @IBAction func showDueReminders(_ sender: Any) {
        calendarPicker.select(Date())
        let date = Date().tomorrow
        let pred = CalendarManager.shared.predicateForIncompleteReminders(withDueDateStarting: Date.distantPast, ending: date, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Due"
            controller.selectedCalendars = []
            controller.selectedPredicate = pred
            controller.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        }
    }
    @IBAction func showUpcomingReminders(_ sender: UIButton) {
        let date = Date().tomorrow
        let pred = CalendarManager.shared.predicateForIncompleteReminders(withDueDateStarting: date, ending: Date.distantFuture, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Upcoming"
            controller.selectedCalendars = []
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

// MARK: - UITableViewDataSource, UITableViewDelegate
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
        let predicate = CalendarManager.shared.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [calendar])
        showReminderController { (controller) in
            controller.title = calendar.title
            controller.navigationController?.navigationBar.barTintColor = Colors.calendar(for: calendar)
            controller.selectedPredicate = predicate
            controller.selectedCalendars = [calendar]
        }
    }

    @objc func fetchCalendar() {
        groupedCalendars = GroupedCalendarBySource()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension CalendarListViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let start = date.midnight
        let end = start.tomorrow
        let predicate = CalendarManager.shared.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        showReminderController { (controller) in
            controller.title = Formats.short(date)
            controller.navigationController?.navigationBar.barTintColor = UIColor.purple
            controller.selectedPredicate = predicate
            controller.selectedCalendars = []
        }

    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarManager.shared.numberOfEventsFor(date)
    }

    @objc func calendarReloadData() {
        CalendarManager.shared.recalculateEventCount {
            DispatchQueue.main.async {
                self.calendarPicker.reloadData()
            }
        }
    }
}
