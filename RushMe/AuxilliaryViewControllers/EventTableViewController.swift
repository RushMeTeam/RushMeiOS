//
//  EventTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/4/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController {

  var selectedEvents : [FratEvent]? = nil {
    didSet {
      self.tableView.isScrollEnabled = selectedEvents != nil
      self.tableView.reloadData()
    }
  }
  
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
  override func tableView(_ tableView: UITableView,
                 canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  
  override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let events = selectedEvents {
      if events.count != 0 {
          if let event = selectedEvents?[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventTBCell") as! EventTableViewCell
            cell.timeLabel.isHidden = false
            cell.fraternityNameLabel.isHidden = false
            cell.eventNameLabel.isHidden = false
            cell.textLabel?.isHidden = true
            let end = event.getEndHours()
            let start = event.getStartHour()
            if start != end {
              let time = start + "-" + end
              cell.timeLabel?.text = time
            }
            cell.eventNameLabel?.text = event.getName()
            
            cell.fraternityNameLabel?.text = event.getOwningFrat().name
            return cell
        }
      }
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell")!
    cell.textLabel?.text = "No events today!"
    cell.textLabel?.textAlignment = .center
    return cell
    
  }
  override func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if let events = selectedEvents {
      return events.count
    }
    return 1
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  


}
