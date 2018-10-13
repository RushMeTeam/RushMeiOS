//
//  EventTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/4/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

fileprivate let tableViewCellIdentifier = "eventTBCell"
fileprivate let basicCellIdentifier = "basicCell"

class EventTableViewController: UITableViewController {
  // Allow cells to provide the date
  // Useful if date is not implied/indicated anywhere else
  var provideDate = false
  // MARK: Member Variables
  var selectedEvents : [Fraternity.Event] = [] {
    didSet {
      tableView.isScrollEnabled = selectedEvents.count > 1
      UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: { 
        self.tableView.reloadData()
      }) { (_) in
        if self.selectedEvents.count > 0 {
          self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
      }
    }
  }
  
  // MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    tableView.allowsSelection = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  // Cannot edit this table!
  override func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if selectedEvents.count > 0 && indexPath.row != selectedEvents.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! EventTableViewCell
      cell.event = selectedEvents[indexPath.row]
      cell.provideDate = provideDate
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier)!
      let numberOfEvents = selectedEvents.count == 0 ? "No" : String(selectedEvents.count) 
      let plural = selectedEvents.count == 1 ? "" : "s"
      cell.textLabel?.text = "\(numberOfEvents) Event\(plural)"
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return selectedEvents.count + 1
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  
  
  
}
