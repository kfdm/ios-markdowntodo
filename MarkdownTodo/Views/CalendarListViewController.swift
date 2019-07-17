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
    private var calendars = GroupedCalendarBySource()
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let myRefreshControl = UIRefreshControl()
    
    @objc func fetchCalendar() {
        CalendarController.shared.authenticated(completionHandler: {
            self.calendars = GroupedCalendarBySource()
            self.myRefreshControl.endRefreshing()
            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = myRefreshControl
        myRefreshControl.addTarget(self, action: #selector(fetchCalendar), for: .valueChanged)
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderListViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCalendar()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cal = CalendarController.shared.calendar(for: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! ReminderListViewController
                controller.selectedCalendar = cal
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
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
        return calendars.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let calendar = calendars.cellForRowAt(indexPath)
        
        cell.textLabel!.text = calendar.title
        cell.textLabel?.textColor = Colors.calendar(for: calendar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendars.titleForHeader(section)
    }
}
