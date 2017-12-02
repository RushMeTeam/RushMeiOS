//
//  CalendarCollectionViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import EventKit

fileprivate let reuseIdentifier = "CalendarCell"

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet weak var collectionView: UICollectionView!
  var eventViewController : EventTableViewController? = nil
  let eventCountThreshold = 3
  var firstEvent : FratEvent? = nil
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var dateLabel: UILabel!
  
  // Shown when share button is selected
  @IBAction func exportEvents(_ sender: UIBarButtonItem) {
    if let url = RushCalendarManager.exportAsICS(events: Array(Campus.shared.favoritedFratEvents)) {
      
      let activityVC = UIActivityViewController(activityItems: [RMMessage.Sharing, url],
                                                applicationActivities: nil)
      
      activityVC.popoverPresentationController?.sourceView = sender.customView
      self.present(activityVC, animated: true, completion: {
        sender.isEnabled = true
      })
    }
    else {
     print("Error in share button!")
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
    //navigationController?.navigationBar.alpha = 1
    navigationController?.navigationBar.backgroundColor = RMColor.AppColor
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
    
    Campus.shared.filterEventsForFavorites()
    self.firstEvent = Campus.shared.favoritedFratEvents.min(by: {
        (thisEvent, thatEvent) in
        return thisEvent.startDate.compare(thatEvent.startDate) == ComparisonResult.orderedAscending
      })
    
    shareButton.isEnabled = Campus.shared.favoritedFratEvents.count != 0
    if (Campus.shared.favoritedFratEvents.count != 0) {
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
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
    cell.setupView()
    if (Campus.shared.favoritedFratEvents.count == 0) {
      cell.eventsLabel?.isHidden = true
      if (indexPath.row < 7) {
        
        cell.dayLabel?.text = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][indexPath.row]
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
    if Calendar.current.isDate(currentDay, inSameDayAs: RMDate.Today) {
      cell.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
      cell.layer.cornerRadius = RMImage.CornerRadius
      cell.layer.masksToBounds = true
    }
    cell.eventsToday = Campus.shared.favoritedFratEvents.filter({
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
      
      if let todaysEvent = collectionCell.eventsToday?.first {
        if Calendar.current.isDate(todaysEvent.startDate, inSameDayAs: RMDate.Today) {
          dateLabel.text = "Today"
         
        }
        else {
          self.dateLabel.text = DateFormatter.localizedString(from: todaysEvent.startDate, dateStyle: .long, timeStyle: .none)
        }
      }
      else {
        dateLabel?.text = " "
      }
    }
    else {
      
      eventViewController?.selectedEvents = nil
    }
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellWidth = collectionView.frame.width/7.5
    var cellHeight = collectionView.frame.height/6.0
    if (indexPath.row < 7) {
      cellHeight = collectionView.frame.height/8.0
    }
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
 
  
}

