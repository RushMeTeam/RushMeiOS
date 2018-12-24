//
//  CalendarCollectionViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "CalendarCell"
fileprivate let labelReuseIdentifier = "DayCell"

class CalendarViewController: UIViewController, 
  UICollectionViewDelegate, 
  UICollectionViewDataSource, 
  UICollectionViewDelegateFlowLayout,
ScrollableItem {
  func updateData() {
    DispatchQueue.main.async {
      self.loadViewIfNeeded()
      self.favoritesSegmentControl.isEnabled = User.preferences.displayFavoritesOnly || Campus.shared.hasFavorites
      self.collectionView.reloadPreservingSelection(animated: true)
      self.scrollView.scrollToTop(animated: true)
      self.favoritesSegmentControl.selectedSegmentIndex = Campus.shared.hasFavorites ? self.favoritesSegmentControl.selectedSegmentIndex : 0
    }
  }
  
  // MARK: Constants
  private(set) var eventViewController : EventTableViewController? = nil
  // MARK: View IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var favoritesSegmentControl: UISegmentedControl!
  // MARK: Recognizer IBOutlets
  @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: Data Source Calculated Fields
  var todayDate : Date {
    get {
      return .today
    }
  }
  func dateKey(from indexPath : IndexPath) -> Date? {
//    guard let dayAdjustedForRow = Calendar.current.date(byAdding: .day, 
//                                        value: indexPath.section%7 - todayDate.weekday, 
//                                        to: todayDate),
//      let dayAdjustedForWeekDayAndWeek = Calendar.current.date(byAdding: .weekOfYear, 
//                                                            value: indexPath.row, 
//                                                            to: dayAdjustedForRow),
//      let fullyAdjustedDay = Calendar.current.date(byAdding: .month, 
//                                                             value: indexPath.section/7, 
//                                                             to: dayAdjustedForWeekDayAndWeek)
    var daysDifference : Int = indexPath.section%7 + indexPath.row*7 - todayDate.weekday%7 
    daysDifference += (indexPath.section/7)*28
    guard let fullyAdjustedDay = Calendar.current.date(byAdding: .day, 
                                                       value: daysDifference, 
                                                       to: todayDate)?.dayDate
      else {
        return nil
    }
//    if (indexPath.section >= 7) {
//     return Calendar.current.date(byAdding: .day, value: 28, to: fullyAdjustedDay)!
//    }
    
//    print("\(fullyAdjustedDay) in month \(month)")
    return fullyAdjustedDay
  }
  
  internal func events(forIndexPath indexPath : IndexPath) -> [Fraternity.Event] {
    guard let today = dateKey(from: indexPath), 
      let todaysEvents = RushCalendar.shared.eventsOn(today)?.filter({ (event) -> Bool in
        return (!viewingFavorites || event.frat.isFavorite) &&
                (User.preferences.considerPastEvents || event.starting >= .today)
      }) else {
        return []
    }
    
    return todaysEvents.sorted(by: <)
  }
  
  var noEvents : Bool {
    return !RushCalendar.shared.hasEvents
  }
  
  var inEventView : Bool {
    get {
      return scrollView.contentOffset.y > collectionView.frame.midX
    }
  }
  
  internal func set(inEventView : Bool) {
    if inEventView {
      scrollView.scrollRectToVisible(bottomView.frame, animated: true) 
    } else {
      scrollView.scrollToTop(animated: true)
    }
  }
  
  var viewingFavorites : Bool {
    get {
      return Campus.shared.hasFavorites && 
             favoritesSegmentControl.selectedSegmentIndex == 1
    }
    set {
      favoritesSegmentControl.selectedSegmentIndex = 0
      favoriteSegmentControlValueChanged(favoritesSegmentControl)
      collectionView.reloadData()
    }
  }
  
  var selectedIndexPath : IndexPath? {
    get {
      return collectionView.indexPathsForSelectedItems?.first
    }
  }
  lazy var zeroIndexPath = IndexPath(item: 0, section: 0)
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var dateLabel: UILabel!
  // MARK: ViewDidLoad and ViewWillAppear
  override func viewDidLoad() {
    super.viewDidLoad()
    // Uncomment the following line to preserve selection between presentations
    
    view.sendSubviewToBack(collectionView)
    collectionView.layer.masksToBounds = true
    collectionView.layer.cornerRadius = 8
    
    scrollView.refreshControl = UIRefreshControl()
    scrollView.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    
    
    eventViewController = children.first as? EventTableViewController
    
    // TODO: Implement multiple day Selection?
    collectionView.allowsMultipleSelection = false
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scrollView.canCancelContentTouches = true
    containerView.layer.masksToBounds = true
    containerView.layer.cornerRadius = 5
    shareButton.isEnabled = !RushCalendar.shared.hasEvents
  }
  
  @objc func handleRefresh() {
    collectionView.reloadPreservingSelection(animated: true)
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites
    scrollView.refreshControl?.endRefreshing()
  }
 
  var fileURL : URL? = nil
  // MARK: Sharing
  // Shown when share button is selected
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
      }
      else {
        // TODO: Fix this so it exports the correct events (favorites or otherwise)
        self.fileURL = self.exportEventsAsICS()
      }
      if let url = self.fileURL {
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
      else {
        print("Error in calendar share button!")
      }
    }
  }
  
  
  // MARK: Button Actions
  @IBAction func favoriteSegmentControlValueChanged(_ sender: UISegmentedControl) {
    let indexPaths = collectionView.indexPathsForSelectedItems!
    for indexPath in indexPaths {
      self.collectionView.deselectItem(at: indexPath, animated: false)
    }
    UIView.transition(with: collectionView, duration: 0.1, options: .transitionCrossDissolve, animations: { 
      self.collectionView.reloadData()
    }) { (_) in }
    for indexPath in indexPaths {
      eventViewController?.selectedEvents = events(forIndexPath: indexPath)
      collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
  }
  // MARK : Gesture Recognizers
  @IBAction func seperatorTap(_ sender: UITapGestureRecognizer) {
    set(inEventView: sender.location(in: view).y < collectionView.frame.maxY)
  }
  
  // MARK: UICollectionViewDataSource
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 14
  }
  func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let basicCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) 
    guard let today = dateKey(from: indexPath) else {
      return basicCell
    }
    guard let cell = basicCell as? CalendarCollectionViewCell else {
      return basicCell 
    }
    cell.set(isGrayedOut: today.month != todayDate.month)
    cell.set(isToday: today.month == todayDate.month && today.day == todayDate.day)
    cell.set(day: today.day, eventCount: events(forIndexPath: indexPath).count)
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, 
                      shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, 
                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return !noEvents
  }
  
  func collectionView(_ collectionView: UICollectionView, 
                      didSelectItemAt indexPath: IndexPath) {
    let todaysEvents = events(forIndexPath: indexPath)
    eventViewController!.selectedEvents = todaysEvents
    if let todaysEvent = todaysEvents.first {
      dateLabel.text =
        DateFormatter.localizedString(from: todaysEvent.starting,
                                      dateStyle: .long,
                                      timeStyle: .none)
      self.dateLabel.text! += Calendar.current.isDate(todaysEvent.starting,
                                                      inSameDayAs: .today) ? " (Today)" : ""
      UISelectionFeedbackGenerator().selectionChanged()
    }
    else {
      dateLabel?.text = " "
    }
  }
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
      
    case UICollectionView.elementKindSectionHeader:
      
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
      return headerView
      
    //case UICollectionView.elementKindSectionFooter:
    default:
      let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath)      
      return footerView
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = collectionView.frame.width/8.5
    let cellHeight = collectionView.frame.height/6.0
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

extension UICollectionView {
  func reloadPreservingSelection(animated : Bool) {
    guard let selectedIP = indexPathsForSelectedItems
      else {
     return   
    }
    reloadData() 
    
    if let reselectIndexPath = selectedIP.first {
      selectItem(at: reselectIndexPath, animated: animated, scrollPosition: .top)
    } 
  }
}

extension CalendarViewController {
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
    let stringICS = User.session.selectedEvents.asICS
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
}


