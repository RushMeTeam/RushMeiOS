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
  // MARK: Member Variables
  private(set) var subscribedEvents : [Fraternity.Event] = []
  private(set) var unsubscribedEvents : [Fraternity.Event] = []
  var selectedEvents : Set<Fraternity.Event> {
    set {
      DispatchQueue.global(qos: .userInteractive).async {
        self.subscribedEvents = newValue.filter({ (event) -> Bool in
          return event.isSubscribed 
        }).sorted(by: <)
        self.unsubscribedEvents = newValue.filter({ (event) -> Bool in
          return !event.isSubscribed
        }).sorted(by: <)
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
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 8
  }
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return section == 0 ? nil : UIView()
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! EventTableViewCell
    let isSubscribed = indexPath.section == 0 && subscribedEvents.count > 0
    let event =  isSubscribed ? subscribedEvents[indexPath.row] : unsubscribedEvents[indexPath.row]
    cell.event = event
    if isSubscribed {
      cell.addButton.tag = -(indexPath.row + 1) 
    } else {
      cell.addButton.tag = indexPath.row + 1
    }
    cell.fratButton.tag = cell.addButton.tag
    cell.addButton.isEnabled = (User.debug.debugDate ?? Date()) < event.starting
  
    cell.fratButton.isEnabled = parent?.canPerformSegue(withIdentifier: "showDetail") ?? false 
    if cell.fratButton.isEnabled {
      cell.fratButton.addTarget(self, action: #selector(fratNavigation(sender:)), for: .touchUpInside)
    } 
    cell.addButton.addTarget(self, action: #selector(toggleAdd), for: .touchUpInside)
    cell.set(isFavorited: isSubscribed)
    return cell
  }
  
  @objc func fratNavigation(sender : UIButton) {
    let row = abs(sender.tag) - 1
    let isSubscribed = sender.tag < 0
    let event = (isSubscribed ? subscribedEvents[row] : unsubscribedEvents[row])
    let fratName = event.frat.name
    let actionVC = UIAlertController(title: event.frat.name + " - " + event.name, message: nil, preferredStyle: .actionSheet)
    actionVC.addAction(UIAlertAction(title: "Copy event details", style: .default, handler: { (action) in
      let end = event.ending.formatToHour()
      let start = event.starting.formatToHour()
      let formatter = DateFormatter.init()
      formatter.dateFormat = "MM.dd.yy"
      let startDate = formatter.string(from: event.starting)
      UIPasteboard.general.strings = [event.name, startDate + " " + start + " - " + end, event.frat.name, event.location ?? event.frat.address ?? event.frat.name.greekLetters + " house"]
    }))
    if let canNavigateToFrat = self.parent?.canPerformSegue(withIdentifier: "showDetail"), canNavigateToFrat {
      actionVC.addAction(UIAlertAction.init(title: event.frat.name.greekLetters + " profile", style: .default, handler: { (action) in
        self.parent?.performSegueIfPossible(withIdentifier: "showDetail", sender: fratName)
      }))
    }
    
    actionVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    self.parent?.present(actionVC, animated: true, completion: nil)
    

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

extension UIViewController {
  func canPerformSegue(withIdentifier id: String) -> Bool {
    guard let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
    return segues.first { $0.value(forKey: "identifier") as? String == id } != nil
  }
  
  /// Performs segue with passed identifier, if self can perform it.
  func performSegueIfPossible(withIdentifier identifier: String?, sender: Any? = nil) {
    guard let _ = identifier, canPerformSegue(withIdentifier: identifier!) else { 
      print("Can't perform segue: \(identifier)")
      return 
    }
    self.performSegue(withIdentifier: identifier!, sender: sender)
  }
}
