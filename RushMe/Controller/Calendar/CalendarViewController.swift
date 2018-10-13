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
      self.favoritesSegmentControl.isEnabled = User.preferences.displayFavoritesOnly
      self.collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
      self.scrollView.scrollToTop(animated: true)
      if !Campus.shared.hasFavorites {
        self.favoritesSegmentControl.selectedSegmentIndex = 0
      }
    }
  }
  
  // MARK: Constants
  var eventViewController : EventTableViewController? = nil
  // MARK: View IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var bottomView: UIView!
  
  @IBOutlet weak var favoritesSegmentControl: UISegmentedControl!
  // MARK: Recognizer IBOutlets
  @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: Data Source Calculated Fields
  var earliestDate : Date? {
    get {
      return RushCalendar.shared.firstEvent?.startDate
      //      return viewingFavorites ?
      //        Campus.shared.firstFavoritedEvent :
      //        Campus.shared.firstEvent
    }
  }
  func dateKey(from indexPath : IndexPath) -> Date? {
    guard indexPath.section == 1, let minDate = earliestDate, 
      let today = Calendar.current.date(byAdding: .day, value: indexPath.row, to: minDate) else {
        return nil
    }
    return today
  }
  
  
  func events(forIndexPath indexPath : IndexPath) -> [Fraternity.Event] {
    guard let today = dateKey(from: indexPath), 
      let todaysEvents = RushCalendar.shared.eventsOn(today) else {
        return []
    }
    return todaysEvents.sorted(by: <)
  }
  var isEmpty : Bool {
    return !RushCalendar.shared.hasEvents
  }
  
  // MARK: Visual Calculated Fields
  var inEventView : Bool {
    get {
      return scrollView.contentOffset.y > collectionView.frame.midX
    }
    set {
      if inEventView {
        // TODO: Figure out why taps are very off and are cancelling
        // touches in other views...
        scrollView.scrollToTop(animated: true)
      }
      else {
        self.scrollView.scrollRectToVisible(bottomView.frame, animated: true) 
      }
    }
  }
  
  var viewingFavorites : Bool {
    get {
      return Campus.shared.hasFavorites && favoritesSegmentControl.selectedSegmentIndex == 1
    }
    set {
      favoritesSegmentControl.selectedSegmentIndex = 0
      self.favoriteSegmentControlValueChanged(favoritesSegmentControl)
      collectionView.reloadData()
      
    }
  }
  
  var selectedIndexPath : IndexPath? {
    get {
      return collectionView.indexPathsForSelectedItems?.first
    }
  }
  lazy var zeroIndexPath = IndexPath.init(item: 0, section: 1)
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var dateLabel: UILabel!
  // MARK: ViewDidLoad and ViewWillAppear
  override func viewDidLoad() {
    super.viewDidLoad()
    //    navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    // Uncomment the following line to preserve selection between presentations
    view.sendSubviewToBack(collectionView)
    collectionView.layer.masksToBounds = true
    collectionView.layer.cornerRadius = 8
    
    
    // Do any additional setup after loading the view.
    if let tbView = children.first as? EventTableViewController {
      eventViewController = tbView
    }
    
    // TODO: Implement Day Selection
    collectionView.allowsMultipleSelection = false
    //Campus.shared.fratNamesObservable.addObserver(forOwner: self, handler: handleNewFrat(oldValue:newValue:))
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fileURL = nil
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites
    shareButton.isEnabled = !RushCalendar.shared.hasEvents
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if collectionView.indexPathsForSelectedItems == nil || collectionView.indexPathsForSelectedItems!.count == 0 {
      collectionView.selectItem(at: zeroIndexPath, animated: false, scrollPosition: .top)
    }
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites
    scrollView.canCancelContentTouches = true
    containerView.layer.masksToBounds = true
    containerView.layer.cornerRadius = 5
    scrollView.refreshControl = UIRefreshControl()
    scrollView.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
  }
  @objc func handleRefresh() {
    collectionView.reloadPreservingSelection(animated: true)
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites
    scrollView.refreshControl?.endRefreshing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
      UIView.animate(withDuration: RMAnimation.ColoringTime) {
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
          UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
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
    UIView.transition(with: collectionView, duration: 0.1, options: .transitionCrossDissolve, animations: { 
      self.collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
    }) { (_) in
      
    }
    
    if collectionView.indexPathsForSelectedItems == nil || collectionView.indexPathsForSelectedItems!.count == 0 {
      if let lastSelectedPath = indexPaths.last {
        eventViewController?.selectedEvents = events(forIndexPath: lastSelectedPath)
        collectionView.selectItem(at: lastSelectedPath, animated: false, scrollPosition: .top)
      }
      
    }
    
    
    
  }
  // MARK : Gesture Recognizers
  @IBAction func seperatorTap(_ sender: UITapGestureRecognizer) {
    if sender.location(in: view).y < collectionView.frame.maxY {
      inEventView = false
    }
  }
  
  // MARK: UICollectionViewDataSource
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? 7 : 31
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let basicCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) 
    guard let today = dateKey(from: indexPath) else {
      let dumbCell = basicCell as! CalendarCollectionViewCell
      let weekday = isEmpty ? indexPath.row : indexPath.row + earliestDate!.weekday
      dumbCell.dayLabel.text = indexPath.section == 0 ? 
        ["M","T","W","T","F","S","S"][weekday%6] : "\(indexPath.row)"
      dumbCell.isSelected = false
      dumbCell.set(isGrayedOut: true)
      return dumbCell
    }
    guard let cell = basicCell as? CalendarCollectionViewCell else {
      return basicCell 
    }
    let eventsToday = events(forIndexPath: indexPath)
    cell.set(isGrayedOut: today.month != Date.today.month)
    cell.set(day: today.day, eventCount: eventsToday.count)
    
    return cell
  }
  
  
  // MARK: - UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, 
                      shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, 
                      shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return indexPath.section != 0 && !isEmpty
  }
  
  func collectionView(_ collectionView: UICollectionView, 
                      didSelectItemAt indexPath: IndexPath) {
    let todaysEvents = events(forIndexPath: indexPath)
    eventViewController!.selectedEvents = todaysEvents
    if let todaysEvent = todaysEvents.first {
      self.dateLabel.text =
        DateFormatter.localizedString(from: todaysEvent.startDate,
                                      dateStyle: .long,
                                      timeStyle: .none)
      self.dateLabel.text! += Calendar.current.isDate(todaysEvent.startDate,
                                                      inSameDayAs: .today) ? " (Today)" : ""
      UISelectionFeedbackGenerator().selectionChanged()
    }
    else {
      dateLabel?.text = " "
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = collectionView.frame.width/8.5
    var cellHeight = collectionView.frame.height/6.0
    if (indexPath.section == 0) {
      cellHeight = collectionView.frame.height/8.0
    }
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

extension UICollectionView {
  func reloadPreservingSelection(animated : Bool) {
    let selectedIP = self.indexPathsForSelectedItems
    self.reloadSections(IndexSet.init(integersIn: 1...1)) 
    if let reselectIndexPath = selectedIP?.first {
      self.selectItem(at: reselectIndexPath, animated: animated, scrollPosition: .top)
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


