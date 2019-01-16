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
  private(set) var subscribedEvents : [Fraternity.Event] = []
  private(set) var unsubscribedEvents : [Fraternity.Event] = []
  var selectedEvents : Set<Fraternity.Event> {
    set {
      DispatchQueue.global(qos: .userInteractive).async {
//        let eventsChronologically = self.selectedEvents.sorted(by: <)
        self.subscribedEvents = newValue.filter({ (event) -> Bool in
          return event.isSubscribed
        })
        self.unsubscribedEvents = newValue.filter({ (event) -> Bool in
          return !event.isSubscribed
        })
        DispatchQueue.main.async {
          self.tableView.isScrollEnabled = newValue.count > 1
          self.tableView.reloadData()
          if newValue.count > 0 {
            self.tableView.scrollToTop(animated: true)
          }
        }
      }
    }
    get {
     return Set<Fraternity.Event>(subscribedEvents + unsubscribedEvents) 
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
    return subscribedEvents.count > 0 ? 2 : 1
  }
  // Cannot edit this table!
  override func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! EventTableViewCell
    let isSubscribed = indexPath.section == 0 && subscribedEvents.count > 0
    let event =  isSubscribed ? subscribedEvents[indexPath.row] : unsubscribedEvents[indexPath.row]
    cell.event = event
    cell.provideDate = provideDate
    if isSubscribed {
      cell.addButton.tag = -(indexPath.row + 1) 
    } else {
      cell.addButton.tag = indexPath.row + 1
    }
    cell.addButton.addTarget(self, action: #selector(toggleAdd), for: .touchUpInside)
    cell.set(isFavorited: isSubscribed)
    return cell
  }
  
  @objc func toggleAdd(sender : UIButton) {
    let row = abs(sender.tag) - 1
    let isSubscribed = sender.tag < 0
    if isSubscribed {
      let event = subscribedEvents.remove(at: row)
      unsubscribedEvents.insert(event, at: 0)
      User.session.selectedEvents.remove(event)
    } else {
      let event = unsubscribedEvents.remove(at: row)
      subscribedEvents.insert(event, at: subscribedEvents.count)
      User.session.selectedEvents.insert(event)
    }
    if (subscribedEvents.count == 0 || (subscribedEvents.count == 1 && !isSubscribed)) {
      tableView.reloadData()
    } else {
      tableView.reloadSections(IndexSet(integersIn: 0...1), with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return section == 0 && subscribedEvents.count > 0 ? subscribedEvents.count : unsubscribedEvents.count
  }
}


