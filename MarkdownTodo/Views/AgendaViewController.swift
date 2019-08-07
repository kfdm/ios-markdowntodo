//
//  OverviewViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/08/07.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import FSCalendar

class AgendaViewController: UIViewController, Storyboarded {
    @IBOutlet weak var calendarPicker: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(calendarReloadData), name: .savedReminder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(calendarReloadData), name: .authenticationGranted, object: nil)

        calendarPicker.appearance.headerMinimumDissolvedAlpha = 0.0

        calendarReloadData()
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

    @IBAction func clickedDue(_ sender: UIButton) {
        calendarPicker.select(Date())
        let date = Date().tomorrow
        let pred = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: Date.distantPast, ending: date, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Due"
            controller.selectedCalendars = []
            controller.selectedPredicate = pred
            controller.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        }
    }

    @IBAction func clickedUpcoming(_ sender: UIButton) {
        let date = Date().tomorrow
        let pred = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: date, ending: Date.distantFuture, calendars: nil)
        showReminderController { (controller) in
            controller.title = "Upcoming"
            controller.selectedCalendars = []
            controller.selectedPredicate = pred
            controller.navigationController?.navigationBar.barTintColor = UIColor.groupTableViewBackground
        }
    }

}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension AgendaViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let start = date.midnight
        let end = start.tomorrow
        let predicate = CalendarAPI.shared.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        showReminderController { (controller) in
            controller.title = Formats.short(date)
            controller.navigationController?.navigationBar.barTintColor = UIColor.purple
            controller.selectedPredicate = predicate
            controller.selectedCalendars = []
        }

    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return CalendarAPI.shared.numberOfEventsFor(date)
    }

    @objc func calendarReloadData() {
        CalendarAPI.shared.recalculateEventCount {
            DispatchQueue.main.async {
                self.calendarPicker.reloadData()
            }
        }
    }
}
