//
//  MasterViewController.swift
//  MarkdownTodo
//
//  Created by Paul Traylor on 2019/07/09.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: ReminderListViewController?
    var objects = [Any]()
    var container = CalendarController.shared

    private let myRefreshControl = UIRefreshControl()

    @objc func configureView() {
        container.setup()
        myRefreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.refreshControl = myRefreshControl
        myRefreshControl.addTarget(self, action: #selector(configureView), for: .valueChanged)
        configureView()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderListViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cal = container.calendar(for: indexPath)
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

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return container.sources.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return container.source(for: section).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cal = container.calendar(for: indexPath)

        cell.textLabel!.text = cal.title
        cell.textLabel?.textColor = Colors.calendar(for: cal)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return container.sources[section].title
    }

}
