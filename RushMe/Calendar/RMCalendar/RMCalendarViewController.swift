//
//  RMCalendarViewController.swift
//  RushMe
//
//  Created by Adam on 1/12/19.
//  Copyright © 2019 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import FSCalendar

class RMCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UIGestureRecognizerDelegate {

  //@IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var calendar: FSCalendar!
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var containerView: UIView!
  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }()
  private(set) var eventViewController : EventTableViewController?
  
  
  
  fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
    [unowned self] in
    let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
    panGesture.delegate = self
    panGesture.minimumNumberOfTouches = 1
//    panGesture.maximumNumberOfTouches = 2
    return panGesture
    }()
  
  override func viewWillAppear(_ animated: Bool) {
    calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell") 

  }
  
  private func configureVisibleCells() {
    calendar.visibleCells().forEach { (cell) in
      let date = calendar.date(for: cell)
      let position = calendar.monthPosition(for: cell)
      self.configure(cell: cell, for: date!, at: position)
    }
  }
  
  func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
    print("did deselect date \(date)")    
    self.configureVisibleCells()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.calendar.appearance.weekdayTextColor = .darkGray
    self.calendar.appearance.headerTitleColor = Frontend.colors.AppColor
    self.calendar.appearance.eventDefaultColor = .gray
    self.calendar.appearance.selectionColor = Frontend.colors.AppColor
    self.calendar.appearance.headerDateFormat = "MMMM yyyy"
    self.calendar.appearance.todayColor = UIColor.gray
    self.calendar.appearance.borderRadius = 1.0
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0.2
    self.calendar.select(User.debug.defaultDate)
    
    self.eventViewController = children.first as? EventTableViewController
    
    self.view.addGestureRecognizer(self.scopeGesture)
    self.eventViewController?.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
    self.calendar.scope = .month
    
    // For UITest
    self.calendar.accessibilityIdentifier = "calendar"
    
  }
  
  deinit {
    print("\(#function)")
  }
  
  // MARK:- UIGestureRecognizerDelegate
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      let velocity = self.scopeGesture.velocity(in: self.view)
      switch self.calendar.scope {
      case .month:
        return velocity.y < 0
      case .week:
        return velocity.y > 0
      }
  }
  func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    self.calendarHeightConstraint.constant = bounds.height.isNaN ? 300 : bounds.height
    self.view.layoutIfNeeded()
  }
  
  func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
    return cell
  }
  
  func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
    self.configure(cell: cell, for: date, at: position)
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//    print("did select date \(self.dateFormatter.string(from: date))")
//    let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
//    print("selected dates is \(selectedDates)")
//    if monthPosition == .next || monthPosition == .previous {
//      calendar.setCurrentPage(date, animated: true)
//    }
    print("did select date \(date)")
    self.configureVisibleCells()
    eventViewController?.selectedEvents = Array(RushCalendar.shared.eventsOn(date) ?? [])
    print("Events on \(date) : \(RushCalendar.shared.eventsOn(date)) ")
    dateLabel.text =
      DateFormatter.localizedString(from: date,
                                    dateStyle: .long,
                                    timeStyle: .none)
    
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    print("\(self.dateFormatter.string(from: calendar.currentPage))")
  }
  
  // MARK:- UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return [2,20][section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let identifier = ["cell_month", "cell_week"][indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
      return cell
    }
  }
  
  
  // MARK:- UITableViewDelegate
  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//    if indexPath.section == 0 {
//      let scope: FSCalendarScope = (indexPath.row == 0) ? .month : .week
//      self.calendar.setScope(scope, animated: true)
//    }
//  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  // MARK:- Target actions
  
//  @IBAction func toggleClicked(sender: AnyObject) {
//    if self.calendar.scope == .month {
//      self.calendar.setScope(.week, animated: true)
//    } else {
//      self.calendar.setScope(.month, animated: true)
//    }
//  }
  private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
    
    let diyCell = (cell as! DIYCalendarCell)
    // Custom today circle
    diyCell.circleImageView.isHidden = !Calendar.autoupdatingCurrent.isDateInToday(date)
    // Configure selection layer
    if position == .current {
      
      var selectionType = SelectionType.none
      
      if calendar.selectedDates.contains(date) {
        let previousDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: date)!
        let nextDate = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: date)!
        if calendar.selectedDates.contains(date) {
          if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
            selectionType = .middle
          }
          else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
            selectionType = .rightBorder
          }
          else if calendar.selectedDates.contains(nextDate) {
            selectionType = .leftBorder
          }
          else {
            selectionType = .single
          }
        }
      }
      else {
        selectionType = .none
      }
      if selectionType == .none {
        diyCell.selectionLayer.isHidden = true
        return
      }
      diyCell.selectionLayer.isHidden = false
      diyCell.selectionType = selectionType
      
    } else {
      diyCell.circleImageView.isHidden = true
      diyCell.selectionLayer.isHidden = true
    }
  }
}
