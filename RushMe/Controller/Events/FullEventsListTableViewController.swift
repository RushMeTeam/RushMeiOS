//
//  EventsTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/9/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

fileprivate let emptyCellReuseIdentifier = "emptyCell"
fileprivate let eventCellReuseIdentifier = "fullEventTBCell"
class FullEventsListTableViewController: UITableViewController, UISearchResultsUpdating {
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  weak var favoritesSegmentControl : UISegmentedControl?
  var viewingFavorites = false {
    didSet {
      dataSource_ = nil
      self.reloadTableView()
    }
  }
  
  private var dataSource_ : [[FratEvent]]? = nil
  var dataSource : [[FratEvent]] {
    get {
      if dataSource_ == nil {
        if viewingFavorites {
         dataSource_ = Campus.shared.favoritedEventsByDay
        }
        else {
         dataSource_ = Campus.shared.eventsByDay 
        }
        if dataSource_!.count == 0 {
          self.tableView.separatorStyle = .none
          self.tableView.isScrollEnabled = false
        }
        else {
         self.tableView.separatorStyle = .singleLine
          self.tableView.isScrollEnabled = true
        }
      }
      return dataSource_!
    }
  }
  
  var emptyDataSource : Bool {
   return dataSource.count == 0
  }
  func reloadTableView() {
    UIView.transition(with: tableView,
                      duration: RMAnimation.ColoringTime/2,
                      options: UIViewAnimationOptions.transitionCrossDissolve,
                      animations: { self.tableView.reloadData() })
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
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem

  }
  override func viewWillAppear(_ animated : Bool) {
    super.viewWillAppear(animated)
    self.favoritesSegmentControl?.isEnabled = Campus.shared.hasFavorites
  }
  func updateSearchResults(for searchController: UISearchController) {
    var newDataSource = [[FratEvent]]()
    let searchText = searchController.searchBar.text ?? ""
    for daysEvents in dataSource {
      let refinedDaysEvents = daysEvents.filter({ (event) -> Bool in
        return event.name.contains(searchText) || event.frat.name.contains(searchText)
      }) 
      if !refinedDaysEvents.isEmpty {
       newDataSource.append(refinedDaysEvents)
      }
    }
    
    dataSource_ = newDataSource
    self.reloadTableView()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
     return nil 
    }
    if self.dataSource.count == 0 {
     return nil
    }
    let indexDate = dataSource[section-1][0].startDate
    var relation = ""
    if Calendar.current.compare(indexDate, to: RMDate.Today, toGranularity: .day) == .orderedSame {
     relation = " (Today)" 
    }
    else if Calendar.current.compare(indexDate.addingTimeInterval(-86400), to: RMDate.Today, toGranularity: .day) == .orderedSame {
     relation = " (Tomorrow)" 
    }
    else if Calendar.current.compare(indexDate.addingTimeInterval(86400), to: RMDate.Today, toGranularity: .day) == .orderedSame {
      relation = " (Yesterday)"
    }
    return DateFormatter.localizedString(from: indexDate, dateStyle: .medium, timeStyle: .none) + relation
  }
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return max(self.dataSource.count+1, 2)
  }
  @objc func segmentControlChanged(sender : UISegmentedControl) {
    viewingFavorites = (sender.selectedSegmentIndex == 1)
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    if self.dataSource.count == 0 {
     return 1
    }
    // #warning Incomplete implementation, return the number of rows
    return self.dataSource[section-1].count
  }
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedControlCell") as! SegmentCell
      cell.segmentControl.addTarget(self, action: #selector(FullEventsListTableViewController.segmentControlChanged), for: UIControlEvents.valueChanged)
      cell.segmentControl.isEnabled = Campus.shared.hasFavorites
      favoritesSegmentControl = cell.segmentControl
      return cell
    }
    if self.dataSource.count == 0 {
     let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellReuseIdentifier)!
      cell.textLabel?.text = "No Events"
      cell.textLabel?.textColor = RMColor.AppColor
      cell.textLabel?.textAlignment = .center
      return cell
    }
    
   let cell = tableView.dequeueReusableCell(withIdentifier: eventCellReuseIdentifier, for: indexPath) as! EventTableViewCell
    cell.event = self.dataSource[indexPath.section-1][indexPath.row]
    return cell
   }
  
  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    var titles = [""]
    for daysEvents in dataSource {
      let dateText = DateFormatter.localizedString(from: daysEvents[0].startDate, dateStyle: .short, timeStyle: .none)
      if Calendar.current.compare(daysEvents[0].startDate, to: RMDate.Today, toGranularity: .day) == .orderedSame {
       titles.append("TDY") 
      }
      else {
        titles.append(String(dateText.dropLast(3)))
      }
    }
    return titles
  }
  
   
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 36 : 64
  }
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }    
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
