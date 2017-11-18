//
//  CalendarCollectionViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import EventKit

private let reuseIdentifier = "CalendarCell"


class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  public static let eventStore = EKEventStore()
  
  @IBOutlet weak var collectionView: UICollectionView!
  //@IBOutlet weak var tableViewController: UITableView!
  var eventViewController : EventTableViewController? = nil
  let eventCountThreshold = 3
  var firstEvent : FratEvent? =  campusSharedInstance.events.min(by: {
    (thisEvent, thatEvent) in
    return
      thisEvent.startDate.compare(
                thatEvent.startDate) == ComparisonResult.orderedAscending
  })
  var lastEvent : FratEvent? = campusSharedInstance.events.min(by: {
    (thisEvent, thatEvent) in
    return
      thisEvent.startDate.compare(
                thatEvent.startDate) != ComparisonResult.orderedAscending
  })
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  
  
  @IBAction func exportEvents(_ sender: UIBarButtonItem) {

    if let url = CalendarManager.exportAsICS(events: Array(campusSharedInstance.events)) {
    
      let activityVC = UIActivityViewController(activityItems: ["Here are all the events I'll be going to this rush!", url], applicationActivities: nil)
      
      activityVC.popoverPresentationController?.sourceView = sender.customView
      self.present(activityVC, animated: true, completion: {
       sender.isEnabled = true
      })
    }
    
  }
  
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
    navigationController?.navigationBar.alpha = 1
    //navigationController?.navigationBar.backgroundColor = COLOR_CONST.MENU_COLOR
    
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    //self.collectionView!.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // Do any additional setup after loading the view.
    if let tbView = self.childViewControllers.first as? EventTableViewController {
      eventViewController = tbView
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    campusSharedInstance.filterEventsForFavorites()
    shareButton.isEnabled = campusSharedInstance.events.count != 0
    if (campusSharedInstance.events.count != 0) {
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: COLOR_CONST.NAVIGATION_BAR_COLOR]
      navigationController?.navigationBar.tintColor = COLOR_CONST.MENU_COLOR
    } else {
      self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
      navigationController?.navigationBar.tintColor = UIColor.lightGray
      drawerButton.tintColor = COLOR_CONST.MENU_COLOR
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
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
    cell.setupView()
    if (campusSharedInstance.events.count == 0) {
      cell.eventsLabel?.isHidden = true
      if (indexPath.row < 7) {
        let weekDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        cell.dayLabel?.text = weekDays[indexPath.row]
      }
      else {
        cell.dayLabel?.text = String(indexPath.row-6)
      }
      return cell
    }
    if (indexPath.row < 7) {
      let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row, to: (self.firstEvent!.startDate))!
      let dateAsString = DateFormatter.localizedString(from: currentDay,
                                                       dateStyle: DateFormatter.Style.full,
                                                       timeStyle: DateFormatter.Style.full)
      cell.dayLabel?.text = String(describing: dateAsString.prefix(3))
      cell.dayLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 10, weight: UIFont.Weight.ultraLight)
      cell.eventsLabel?.isHidden = true
      return cell
    }
    let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row-7, to: (self.firstEvent!.startDate))!
    cell.eventsToday = campusSharedInstance.events.filter ({
     (event) in
      return Calendar.current.compare(currentDay, to: event.startDate, toGranularity: .day) == ComparisonResult.orderedSame
    })
    if (cell.eventsToday!.count == 0){
      cell.eventsToday = nil
    }
    
    cell.dayLabel.text = String(Calendar.current.dateComponents([.day], from: currentDay).day!)
    if let numberOfEventsToday = cell.eventsToday?.count {
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
    if (indexPath.row < 7) {
     return
    }
    if let collectionCell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
      eventViewController?.selectedEvents = collectionCell.eventsToday
    }
    else {
      eventViewController?.selectedEvents = nil
    }
  }
  
 
  
}

