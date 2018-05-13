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
      self.collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
      self.scrollView.scrollToTop(animated: true)
      self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites
      if !Campus.shared.hasFavorites {
        self.favoritesSegmentControl.selectedSegmentIndex = 0
      }
      self.viewWillAppear(true)
    }
  }
  
  // MARK: Constants
  var eventViewController : EventTableViewController? = nil
  fileprivate let eventCountThreshold = 9
  // MARK: View IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var bottomView: UIView!
  
  @IBOutlet weak var favoritesSegmentControl: UISegmentedControl!
  // MARK: Recognizer IBOutlets
  @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: Data Source Calculated Fields
  var firstEvent : FratEvent? {
    get {
      return Campus.shared.firstEvent
      //      return viewingFavorites ?
      //        Campus.shared.firstFavoritedEvent :
      //        Campus.shared.firstEvent
    }
  }
  var dataSource : [[FratEvent]] {
    return viewingFavorites ? Campus.shared.eventsByDay : Campus.shared.favoritedEventsByDay
  }
  var flatDataSource : Set<FratEvent> {
    get {
      return viewingFavorites ?
        Campus.shared.favoritedEvents :
        Campus.shared.allEvents
    }
  }
  func events(forIndexPath indexPath : IndexPath) -> [FratEvent] {
    if (indexPath.row < 7 || firstEvent == nil) {
      return []
    }
    let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row-7, to: (firstEvent!.startDate))!
    let todaysEvents = flatDataSource.filter({
      (event) in
      return Calendar.current.compare(currentDay, to: event.startDate, toGranularity: .day) == ComparisonResult.orderedSame
    })
    return todaysEvents.sorted(by: { (first, second) -> Bool in
      return first.startDate < second.startDate
    })
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
  var favoritesShouldBeEnabled : Bool {
    get {
      return Campus.shared.favoritedEvents.count != 0
    }
  }
  var selectedIndexPath : IndexPath? {
    get {
      return collectionView.indexPathsForSelectedItems?.first
    }
  }
  lazy var zeroIndexPath = IndexPath.init(item: 7, section: 0)
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var dateLabel: UILabel!
  // MARK: ViewDidLoad and ViewWillAppear
  override func viewDidLoad() {
    super.viewDidLoad()
    //    navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    self.view.sendSubview(toBack: collectionView)
    
    
    
    // Do any additional setup after loading the view.
    if let tbView = self.childViewControllers.first as? EventTableViewController {
      eventViewController = tbView
    }
    
    // TODO: Implement Day Selection
    collectionView.allowsMultipleSelection = false
    //Campus.shared.fratNamesObservable.addObserver(forOwner: self, handler: handleNewFrat(oldValue:newValue:))
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.fileURL = nil
    favoritesSegmentControl.isEnabled = favoritesShouldBeEnabled
    shareButton.isEnabled = flatDataSource.count != 0
    
    
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if collectionView.indexPathsForSelectedItems == nil || collectionView.indexPathsForSelectedItems!.count == 0 {
      collectionView.selectItem(at: zeroIndexPath, animated: false, scrollPosition: .top)
    }
    scrollView.canCancelContentTouches = true
    containerView.layer.masksToBounds = true
    containerView.layer.cornerRadius = 5
    scrollView.refreshControl = UIRefreshControl()
    scrollView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
  }
  @objc func handleRefresh() {
    collectionView.reloadPreservingSelection(animated: true)
    scrollView.refreshControl?.endRefreshing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */
  
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
        self.fileURL = RMCalendarManager.exportAsICS(events: Campus.shared.favoritedEvents)
      }
      if let url = self.fileURL {
        let activityVC = UIActivityViewController(activityItems: [RMMessage.Sharing, url],
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
    if sender.location(in: collectionView).y > collectionView.frame.height {
      inEventView = !inEventView          
    }
  }
  
  
  // MARK: Animation Calculated Fields
  
  // MARK: UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 31+7
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
    cell.isSelected = false
    if (firstEvent == nil) {
      cell.eventsLabel?.isHidden = true
      cell.dayLabel?.textColor = UIColor.gray
      // cell.dayLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 7, weight: UIFont.Weight.ultraLight)
      if (indexPath.row < 7) {
        cell.dayLabel?.text = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][indexPath.row]
      }
      else {
        cell.dayLabel?.text = String(indexPath.row-6)
      }
      return cell
    }
    
    if (indexPath.row < 7) {
      let labelCell = collectionView.dequeueReusableCell(withReuseIdentifier: labelReuseIdentifier, for: indexPath) as! CalendarLabelCollectionViewCell
      let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row, to: (firstEvent!.startDate))!
      let dateAsString = DateFormatter.localizedString(from: currentDay,
                                                       dateStyle: DateFormatter.Style.full,
                                                       timeStyle: DateFormatter.Style.full)
      labelCell.dayLabel?.text = String(describing: dateAsString.prefix(3))
      labelCell.dayLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 7, weight: UIFont.Weight.ultraLight)
      return labelCell
    }
    let eventsToday = events(forIndexPath: indexPath)
    cell.eventsToday = eventsToday.count == 0 ? nil : eventsToday
    let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row-7, to: (firstEvent!.startDate))!
    let currentMonth = Calendar.current.component(Calendar.Component.month, from: currentDay)
    let todaysMonth = Calendar.current.component(Calendar.Component.month, from: RMDate.Today)
    cell.dayTextColor = currentMonth == todaysMonth ? UIColor.black : UIColor.lightGray
    cell.dayLabel.text = String(Calendar.current.dateComponents([.day], from: currentDay).day!)
    if let numberOfEventsToday = cell.eventsToday?.count {
      cell.eventsLabel.isHidden = false
      if (numberOfEventsToday <= eventCountThreshold) {
        cell.eventsLabel.text = String(numberOfEventsToday)
      }
      else {
        cell.eventsLabel.text = String(eventCountThreshold) + "+"
      }
    }
    else {
      cell.eventsLabel.isHidden = true
    }
    
    return cell
  }
  
  
  // MARK: - UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  //  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
  //    return indexPath.row > 6 && firstEvent != nil
  //  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    eventViewController!.selectedEvents = events(forIndexPath: indexPath)
    if let collectionCell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
      if let todaysEvent = collectionCell.eventsToday?.first {
        self.dateLabel.text =
          DateFormatter.localizedString(from: todaysEvent.startDate,
                                        dateStyle: .long,
                                        timeStyle: .none) + (Calendar.current.isDate(todaysEvent.startDate,
                                                                                     inSameDayAs: RMDate.Today) ? " (Today)" : "")
        //collectionCell.backgroundColor = UIColor.blue
        
        UISelectionFeedbackGenerator().selectionChanged()
      }
      else {
        dateLabel?.text = " "
      }
    }
    else {
      eventViewController!.selectedEvents = nil
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = collectionView.frame.width/8.0
    var cellHeight = collectionView.frame.height/6.0
    if (indexPath.row < 7) {
      cellHeight = collectionView.frame.height/8.0
    }
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

extension UICollectionView {
  func reloadPreservingSelection(animated : Bool) {
    let selectedIP = self.indexPathsForSelectedItems
    self.reloadSections(IndexSet.init(integersIn: 0...0)) 
    if let reselectIndexPath = selectedIP?.first {
      self.selectItem(at: reselectIndexPath, animated: animated, scrollPosition: .top)
    } 
  }
}

