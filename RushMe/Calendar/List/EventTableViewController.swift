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
    tableView.allowsSelection = true
    tableView.allowsMultipleSelection = false
  }
  
  // MARK: - Table view data source  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return subscribedEvents.count > 0 ? 2 : 1
  }
  
  override func tableView(_ tableView: UITableView,
                          canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  override func tableView(_ tableView: UITableView, 
                          heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 8
  }
  
  override func tableView(_ tableView: UITableView, 
                          viewForHeaderInSection section: Int) -> UIView? {
    return section == 0 ? nil : UIView()
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let selectedPath = tableView.indexPathsForSelectedRows?.first,
      selectedPath == indexPath {
      return 108
    } else {
      return 76 
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let event =  indexPath.section == 0 && subscribedEvents.count > 0 ? subscribedEvents[indexPath.row] : unsubscribedEvents[indexPath.row] 
    Backend.log(action: .SelectedEvent(event))
    
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return section == 0 && subscribedEvents.count > 0 ? subscribedEvents.count : unsubscribedEvents.count
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier) as! EventTableViewCell
    let isSubscribed = indexPath.section == 0 && subscribedEvents.count > 0
    let event =  isSubscribed ? subscribedEvents[indexPath.row] : unsubscribedEvents[indexPath.row]
    cell.set(event: event)
    cell.set(isFavorited: isSubscribed)
    
    if isSubscribed {
      cell.addButton.tag = -(indexPath.row + 1) 
    } else {
      cell.addButton.tag = indexPath.row + 1
    }
    cell.calendarButton.tag = cell.addButton.tag
    cell.clipboardButton.tag = cell.addButton.tag
    cell.fratButton.tag = cell.addButton.tag
    configure(cell, for: event)
    return cell
  }
  
  func configure(_ cell : EventTableViewCell, for event : Fraternity.Event) {
    cell.addButton.isEnabled = (User.debug.debugDate ?? Date()) < event.starting
    cell.fratButton.isEnabled = parent?.canPerformSegue(withIdentifier: "showDetail") ?? false 
    if cell.fratButton.isEnabled {
      cell.fratButton.addTarget(self, action: #selector(fratNavigation(sender:)), for: .touchUpInside)
    } 
    cell.addButton.addTarget(self, action: #selector(toggleAdd), for: .touchUpInside)
    cell.calendarButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
    cell.clipboardButton.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
  }
  @objc func showCalendar(sender : UIButton) {
    guard let event = getEvent(for: sender.tag),
      let calendar = event.frat.calendarImagePath else {
        return   
    }
    let imageVC = UIStoryboard.main.imageVC
    imageVC.addVisualEffectView()
    
    parent?.present(imageVC, animated: true) {
      imageVC.setImage(with: calendar)
    }
    
  }
  
  @objc func copyToClipboard(sender : UIButton) {
    guard let event = getEvent(for: sender.tag) else {
      return 
    }
    let end = event.ending.formatToHour()
    let start = event.starting.formatToHour()
    let formatter = DateFormatter.init()
    formatter.dateFormat = "MM.dd.yy"
    let startDate = formatter.string(from: event.starting)
    let copiedString = [event.name, startDate + " " + start + " - " + end, event.frat.name, event.location ?? event.frat.address ?? event.frat.name.greekLetters + " house"]
    UIPasteboard.general.strings = copiedString
    sender.setTitle("Copied", for: .normal)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      sender.setTitle("Copy to Clipboard", for: .normal)
    }
  }
  
  func getEvent(for tag : Int) -> Fraternity.Event? {
    let row = abs(tag) - 1
    let isSubscribed = tag < 0
    let event = (isSubscribed ? subscribedEvents[row] : unsubscribedEvents[row])
    return event
  }
  
  @objc func fratNavigation(sender : UIButton) {
    let row = abs(sender.tag) - 1
    let isSubscribed = sender.tag < 0
    let event = (isSubscribed ? subscribedEvents[row] : unsubscribedEvents[row])
    let fratName = event.frat.name
    self.parent?.performSegueIfPossible(withIdentifier: "showDetail", sender: fratName)
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
}

extension UIViewController {
  func canPerformSegue(withIdentifier id: String) -> Bool {
    guard let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { 
      return false 
    }
    return segues.first { $0.value(forKey: "identifier") as? String == id } != nil
  }
  /// Performs segue with passed identifier, if self can perform it.
  func performSegueIfPossible(withIdentifier identifier: String?, sender: Any? = nil) {
    guard let _ = identifier, canPerformSegue(withIdentifier: identifier!) else { 
      print("Can't perform segue: \(String(describing: identifier))")
      return 
    }
    self.performSegue(withIdentifier: identifier!, sender: sender)
  }
}
