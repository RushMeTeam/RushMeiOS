//
//  RMCalendarViewController.swift
//  RushMe
//
//  Created by Adam on 1/12/19.
//  Copyright © 2019 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import FSCalendar

class RMCalendarViewController: FSCalendarViewController, FSCalendarDelegate, FSCalendarDataSource, UIGestureRecognizerDelegate {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var containerView: UIView!
  
  fileprivate lazy var dateFormatter: DateFormatter = 
  {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }()
  
  private var eventViewController : EventTableViewController! {
    get {
      return children.first as? EventTableViewController
    }
  }
  
  fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
    [unowned self] in
    let panGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)))
    panGesture.delegate = self
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 2
    return panGesture
    }()
  
  override func viewWillAppear(_ animated: Bool) {
    calendar.reloadData()
    if let (_, end) = RushCalendar.shared.dateRange,
      end < .today {
      calendar.select(end)
    } else {
      calendar.select(.today)
      calendar(calendar, didSelect: .today, at: .current)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    calendar.register(RMCalendarCell.self, forCellReuseIdentifier: "cell") 

    self.calendar.appearance.weekdayTextColor = .darkGray
    self.calendar.appearance.headerTitleColor = Frontend.colors.AppColor
    self.calendar.appearance.eventDefaultColor = Frontend.colors.AppColor
    self.calendar.appearance.eventSelectionColor = Frontend.colors.AppColor
    self.calendar.appearance.selectionColor = Frontend.colors.SelectionColor
    self.calendar.appearance.todayColor = .lightGray
    self.calendar.today = Date()
    self.calendar.weekdayHeight = 10
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0.2
    self.calendar.placeholderType = .none
    self.calendar.appearance.headerDateFormat = "MMMM YYYY"
    
    self.view.addGestureRecognizer(self.scopeGesture)
    self.eventViewController?.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
    self.calendar.scope = .month
    
    // For UITest
    self.calendar.accessibilityIdentifier = "FSCalendar"
    calendar.select(.today)
  }
  
  var fileURL : URL? = nil
  
  @IBAction func exportEvents(_ sender: UIBarButtonItem) {
    DispatchQueue.main.async {
      let overlayView = UIView(frame: self.view.frame)
      overlayView.center = self.view.center
      overlayView.alpha = 0
      overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
      overlayView.center.y -= 64
      UIView.animate(withDuration: Frontend.animations.defaultDuration) {
        overlayView.alpha = 1
      }
      self.view.addSubview(overlayView)
      if let _ = self.fileURL {
        // Do nothing-- already loaded
        return
      }
      else {
        // TODO: Fix this so it exports the correct events (favorites or otherwise)
        self.fileURL = self.exportEventsAsICS()
      }
      guard let url = self.fileURL else {
        print("Error in calendar share button!")
        return
      }
      let activityVC = UIActivityViewController(activityItems: [Frontend.text.shareMessage, url],
                                                applicationActivities: nil)
      activityVC.popoverPresentationController?.sourceView = sender.customView
      self.present(activityVC, animated: true, completion: {
        sender.isEnabled = true
        UIView.animate(withDuration: Frontend.animations.defaultDuration, animations: {
          overlayView.alpha = 0
        }, completion: { (completed) in
          overlayView.removeFromSuperview()
        })
      })
    }
  }
  /*
   Saves a .ics file to the app's document directory, and
   returns the location at which the document was saved, if
   it was saved. If it was not saved, the URL will be nil!
   
   The exportAsICS function makes good use of the iCalKit
   open-source framework, a software bundle used to describe
   Apple's Date-type as .ics VEvents, all within a VCalendar.
   
   The function has two main components: firstly, it creates
   an ICS file, and secondly it saves that file to the disk.
   
   */
  fileprivate func exportEventsAsICS() -> URL? {
    let stringICS = User.session.selectedEvents.filter({ (event) -> Bool in
      return event.starting > Date()
    }).asICS
    // Try(!) to find a place to save this file
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    // Create the path, name the file "fratEvents.ics"
    let saveFileURL = path.appendingPathComponent("/fratEvents.ics")
    // Try(!) to save the file, handle all throws below
    do {
      try stringICS.write(to: saveFileURL, atomically: true, encoding: String.Encoding.ascii)
    }
      // If there are any errors, they are printed here
    catch let e {
      print(e.localizedDescription)
      return nil
    }
    // Success-- return where the file was saved.
    return saveFileURL
  } 
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "showDetail", 
          let fratName = sender as? String, 
          let selectedFraternity = Campus.shared.fraternitiesByName[fratName] 
      else {
      return
    }
    Backend.log(action: .Selected(fraternity: selectedFraternity))
    let controller = segue.destination as! UIPageViewController
    controller.title = fratName.greekLetters
    controller.view.backgroundColor = .white
    let dVC = UIStoryboard.main.detailVC
    dVC.selectedFraternity = selectedFraternity
    controller.setViewControllers([dVC], direction: .forward, animated: false)
  }
  
  // MARK:- UIGestureRecognizerDelegate
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let velocity = scopeGesture.velocity(in: view)
    switch calendar.scope {
    case .month:
      return velocity.y < 0
    case .week:
      return velocity.y > 0
    }
  }
  
  private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
    let diyCell = (cell as! RMCalendarCell)
    // Custom today circle
    //diyCell.tintColor = 
    (diyCell.circleView as? UIImageView)?.tintColor = date >= .today ? Frontend.colors.SelectionColor : .gray
    diyCell.circleView.isHidden = !Calendar.autoupdatingCurrent.isDateInToday(date)
  }
  
  private func configureVisibleCells() {
    calendar.visibleCells().forEach { (cell) in
      let date = calendar.date(for: cell)
      let position = calendar.monthPosition(for: cell)
      configure(cell: cell, for: date!, at: position)
    }
  }
  
  func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
    configureVisibleCells()
  }
  
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let count = RushCalendar.shared.eventsOn(date).count
    return count
  }
  
  func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    calendarHeightConstraint.constant = bounds.height.isNaN ? 300 : bounds.height
    view.layoutIfNeeded()
  }
  
  func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! RMCalendarCell
    return cell
  }
  
  func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
    configure(cell: cell, for: date, at: position)
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    if monthPosition == .next || monthPosition == .previous {
      calendar.setCurrentPage(date, animated: true)
    }
    guard let eventListVC = eventViewController else {
      print("No eventListVC!")
      return
    }
    let events = RushCalendar.shared.eventsOn(date)
    let eventCount = events.count
    eventListVC.selectedEvents = events
    dateLabel.text = "\(eventCount == 0 ? "No" : String(eventCount)) Event\(eventCount == 1 ? "" : "s")"
    UISelectionFeedbackGenerator().selectionChanged()
  }
  
}

class FSCalendarViewController : UIViewController {
  @IBOutlet weak var calendar: FSCalendar!
}
