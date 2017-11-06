//
//  CalendarCollectionViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CalendarCell"

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet weak var childView: UIView!
  
  @IBOutlet weak var collectionView: UICollectionView!
  //@IBOutlet weak var tableViewController: UITableView!
  var eventViewController : EventTableViewController? = nil
  let eventCountThreshold = 3
  let sqlHandler = sharedSQLHandler
//  var events : Set<FratEvent> = campusSharedInstance.events
//  var favoriteFrats : [String] = campusSharedInstance.favorites
  var firstEvent : FratEvent? =  campusSharedInstance.events.min(by: {
    (thisEvent, thatEvent) in return thisEvent.getStartDate().compare(thatEvent.getStartDate()) == ComparisonResult.orderedAscending
  })
  var lastEvent : FratEvent? = campusSharedInstance.events.min(by: {
    (thisEvent, thatEvent) in return thisEvent.getStartDate().compare(thatEvent.getStartDate()) != ComparisonResult.orderedAscending
  })
  var selectedEvents : [FratEvent]? = nil
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  
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
    navigationController?.navigationBar.tintColor = COLOR_CONST.MENU_COLOR
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: COLOR_CONST.NAVIGATION_BAR_COLOR]
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
    //self.collectionView!.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // Do any additional setup after loading the view.
    if let tbView = self.childViewControllers.first as? EventTableViewController {
      eventViewController = tbView
    }
    self.collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.top)
    
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    campusSharedInstance.filterEventsForFavorites()
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
//    if (firstEvent == nil || lastEvent == nil) {
//      return 0
//    }
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
        cell.dayLabel?.text = String(indexPath.row-7)
      }
      return cell
    }
    if (indexPath.row < 7) {
      let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row, to: (self.firstEvent!.getStartDate()))!
      let dateAsString = DateFormatter.localizedString(from: currentDay, dateStyle: DateFormatter.Style.full, timeStyle: DateFormatter.Style.full)
      cell.dayLabel?.text = String(describing: dateAsString.prefix(3))
      cell.dayLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 10, weight: UIFont.Weight.ultraLight)
      cell.eventsLabel?.isHidden = true
      return cell
    }
    let currentDay = Calendar.current.date(byAdding: .day, value: indexPath.row-7, to: (self.firstEvent!.getStartDate()))!
    cell.eventsToday = campusSharedInstance.events.filter ({
     (event) in
      return Calendar.current.compare(currentDay, to: event.getStartDate(), toGranularity: .day) == ComparisonResult.orderedSame
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
  
  // MARK: UICollectionViewDelegate
  
  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */
  
  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
   
   }
   */
  
  // MARK : UITableViewDataSource
  
}

