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

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  // MARK: Member Variables
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var seperatorView: UIView!
  @IBOutlet weak var favoritesSegmentControl: UISegmentedControl!
  
  @IBOutlet weak var toolbarView: UIView!
  
  var inEventView : Bool {
    get {
     return self.seperatorView.center.y <= self.collectionView.center.y
    }
    set {
      self.animate(finalState: newValue ? self.topState : self.bottomState)
    }
  }
  var panCutoff : CGFloat {
    get {
     return self.collectionView.center.y + 32
    }
  }
  @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
  @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
  
  var eventViewController : EventTableViewController? = nil
  let eventCountThreshold = 9
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
  var firstEvent : FratEvent? { 
    get {
      return viewingFavorites ? 
        Campus.shared.firstFavoritedEvent : 
        Campus.shared.firstEvent
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
  var favoritesShouldBeEnabled : Bool {
    get {
     return Campus.shared.favoritedEvents.count != 0
    }
  }
  var selectedIndexPath : IndexPath? = nil

  
  func events(forIndexPath indexPath : IndexPath) -> [FratEvent] {
    if (indexPath.row < 7 || firstEvent == nil) {
      return []
    }
    let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row-7, to: (firstEvent!.startDate))!
    return flatDataSource.filter({
      (event) in
      return Calendar.current.compare(currentDay, to: event.startDate, toGranularity: .day) == ComparisonResult.orderedSame
    })
  }
  
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var dateLabel: UILabel!
  var fileURL : URL? = nil
  // MARK: Sharing
  // Shown when share button is selected
  @IBAction func exportEvents(_ sender: UIBarButtonItem) {
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
  // MARK: ViewDidLoad and ViewWillAppear
  override func viewDidLoad() {
    super.viewDidLoad()
    if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      drawerButton.target = self.revealViewController()
      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
      // Allow drag to open drawer, tap out to close
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
    navigationController?.navigationBar.isTranslucent = false
    //navigationController?.navigationBar.alpha = 1
    navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    self.containerView.backgroundColor = UIColor.clear
    self.seperatorView.layer.cornerRadius = RMImage.CornerRadius*2
    if #available(iOS 11.0, *) {
      self.seperatorView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
    } else {
      // Fallback on earlier versions
    }
    // Do any additional setup after loading the view.
    if let tbView = self.childViewControllers.first as? EventTableViewController {
      eventViewController = tbView
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.fileURL = nil
    viewingFavorites = favoritesShouldBeEnabled
    DispatchQueue.global().async {
      self.fileURL =
        RMCalendarManager.exportAsICS(events: Campus.shared.favoritedEvents)
    }
    favoritesSegmentControl.isEnabled = favoritesShouldBeEnabled
    shareButton.isEnabled = flatDataSource.count != 0
    panGestureRecognizer.isEnabled = shareButton.isEnabled
    tapGestureRecognizer.isEnabled = panGestureRecognizer.isEnabled
    if let _ = firstEvent {
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
      navigationController?.navigationBar.tintColor = RMColor.AppColor
    } else {
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
      navigationController?.navigationBar.tintColor = UIColor.lightGray
      drawerButton.tintColor = RMColor.AppColor
    }
    
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
  
  // MARK: UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 31+7
  }
  
  @IBAction func favoriteSegmentControlValueChanged(_ sender: UISegmentedControl) {
    self.collectionView.reloadData()
    if let indexPath = selectedIndexPath {
      let eventsToday = events(forIndexPath: indexPath)
      if let todaysEvent = eventsToday.first {
        self.dateLabel.text = 
          DateFormatter.localizedString(from: todaysEvent.startDate, 
                                        dateStyle: .long, 
                                        timeStyle: .none) + (Calendar.current.isDate(todaysEvent.startDate, 
                                                                                     inSameDayAs: RMDate.Today) ? " (Today)" : "")
      }
      else {
       self.dateLabel.text = "" 
      }
      self.eventViewController?.selectedEvents = eventsToday
    }
    else {
     self.eventViewController?.selectedEvents = nil
    }
    
    
  }
  
  @IBAction func seperatorTap(_ sender: UITapGestureRecognizer) {
    inEventView = !inEventView
  }
  @IBAction func eventCalendarPan(_ sender: UIPanGestureRecognizer) {
    let yLoc = min(max(sender.location(in: self.view).y, self.seperatorView.frame.height/2), self.collectionView.frame.height+self.seperatorView.frame.height/2)
    switch sender.state {
    case .possible:
      return
    case .began:
      return
    case .changed:
      seperatorView.center.y = yLoc
      containerView.frame.origin.y = seperatorView.frame.maxY
      containerView.frame.size.height = self.eventTableViewControllerBottom - self.containerView.frame.origin.y
    case .ended:
      inEventView = yLoc <= panCutoff
    case .cancelled:
      return
    case .failed:
      return
    }
    
  }
  var eventTableViewControllerBottom : CGFloat {
    get {
      return toolbarView.frame.minY
    }
  }
  func animate(finalState : @escaping () -> ()) {
    UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
      finalState()
    }, completion: nil)
  }
  var topState : () -> () {
    get {
      return {
        self.seperatorView.center.y = self.collectionView.center.y/2
        self.containerView.frame.origin.y = self.seperatorView.frame.maxY
        self.containerView.frame.size.height = self.eventTableViewControllerBottom - self.containerView.frame.origin.y
      }
    }
  }
  
  var bottomState : () -> () {
    get {
      return {
        self.seperatorView.center.y = self.collectionView.frame.height+self.seperatorView.frame.height/2
        self.containerView.frame.origin.y = self.seperatorView.frame.maxY
        self.containerView.frame.size.height = self.eventTableViewControllerBottom - self.containerView.frame.origin.y
      }
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    inEventView = false
    selectedIndexPath = indexPath
    eventViewController!.selectedEvents = events(forIndexPath: indexPath)
    if let collectionCell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
      if let todaysEvent = collectionCell.eventsToday?.first {
        self.dateLabel.text =
          DateFormatter.localizedString(from: todaysEvent.startDate,
                                        dateStyle: .long,
                                        timeStyle: .none) + (Calendar.current.isDate(todaysEvent.startDate,
                                                                                     inSameDayAs: RMDate.Today) ? " (Today)" : "")
        //collectionCell.backgroundColor = UIColor.blue
        
      }
      else {
        dateLabel?.text = " "
      }
    }
    else {
      eventViewController!.selectedEvents = nil
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
    cell.isSelected = false
    if (firstEvent == nil) {
      cell.eventsLabel?.isHidden = true
      cell.dayLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 7, weight: UIFont.Weight.ultraLight)
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
    if Calendar.current.isDate(currentDay, inSameDayAs: RMDate.Today) {
      cell.dayLabel.attributedText = NSAttributedString.init(string: cell.dayLabel.text!, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle])
    }
    else {
     cell.dayLabel.attributedText = NSAttributedString.init(string: cell.dayLabel.text!)
    }
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
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    
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

