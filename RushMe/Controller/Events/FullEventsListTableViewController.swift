//
//  EventsTableViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/9/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class FullEventsListTableViewController: UITableViewController, UISearchResultsUpdating {
  
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  @IBOutlet var favoritesButton: UIBarButtonItem!
  
  var viewingFavorites = false {
    didSet {
      if !viewingFavorites {
        //favoritesBarButton.image = RMImage.FavoritesImageUnfilled
        favoritesButton.title = "Favorites"
      }
      else {
        //favoritesBarButton.image = RMImage.FavoritesImageFilled
        favoritesButton.title = "All"
      }
      dataSource_ = nil
      self.reloadTableView()
      refreshControl?.isEnabled = !viewingFavorites
      self.favoritesButton.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
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
      }
      return dataSource_!
    }
  }
  func reloadTableView() {
    UIView.transition(with: tableView,
                      duration: RMAnimation.ColoringTime/2,
                      options: UIViewAnimationOptions.transitionCrossDissolve,
                      animations: { self.tableView.reloadData() })
  }
  @IBAction func favoritesButtonToggled(_ sender: UIBarButtonItem) {
    viewingFavorites = !viewingFavorites
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
    self.favoritesButton.isEnabled = Campus.shared.hasFavorites

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
    return DateFormatter.localizedString(from: self.dataSource[section][0].startDate, dateStyle: .medium, timeStyle: .none)
  }
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return self.dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.dataSource[section].count
  }
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "fullEventTBCell", for: indexPath) as! EventTableViewCell
    cell.event = self.dataSource[indexPath.section][indexPath.row]
    return cell
   }
  
  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    var titles = [String]()
    for daysEvents in dataSource {
      let dateText = DateFormatter.localizedString(from: daysEvents[0].startDate, dateStyle: .short, timeStyle: .none)
       
      titles.append(String(dateText.dropLast(3)))
    }
    return titles
  }
  
   
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
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
