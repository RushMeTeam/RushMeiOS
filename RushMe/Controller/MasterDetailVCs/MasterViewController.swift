//
//  MasterViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
// Pushed Mon at 1:02 PM at Chi Phi
import UIKit
// Commit test comment
// Master view controller, a subclass of UITableViewController,
// provides the main list of fraternities from which a user can
// select in order to find detail.
// Notes:
//    -- Allows 3DTouch
//    -- Is the SWRevealViewController's .front view controller
//          -- Set in AppDelegate
let LOADIMAGES = true
class MasterViewController : UITableViewController {
  
  // The hard data used in the table
  var lastPullDescription = ""
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  // MARK: SQL
  let sqlHandler = sharedSQLHandler
  var viewingFavorites = false
  
  @IBAction func favoritesToggled(_ sender: UIBarButtonItem) {
    if (refreshControl!.isRefreshing) {
      return
    }
    if !viewingFavorites {
      sender.image = UIImage(named: "FavoritesIcon")
    }
    else {
      sender.image = UIImage(named: "FavoritesUnfilled")
    }
    viewingFavorites = !viewingFavorites
    refreshControl?.isEnabled = !viewingFavorites
    self.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    if (!COLOR_CONST.SLIDEOUT_MENU_SHADOW_ENABLED) {
      self.revealViewController().frontViewShadowOpacity = 0
    }
    if let VC = self.revealViewController().rearViewController as? DrawerMenuViewController {
      VC.masterVC = self.splitViewController
    }
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.alpha = 1
    //navigationController?.navigationBar.backgroundColor = COLOR_CONST.MENU_COLOR
    navigationController?.navigationBar.tintColor = COLOR_CONST.MENU_COLOR
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: COLOR_CONST.NAVIGATION_BAR_COLOR]
    
    openBarButtonItem.tintColor = COLOR_CONST.MENU_COLOR
    // Ensure the menu button toggles the menu
    openBarButtonItem.target = self
    openBarButtonItem.action = #selector(self.toggleViewControllers(_:))
    
    // Allows for drag to open and tap out to close
    
    
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = COLOR_CONST.MENU_COLOR
    refreshControl?.tintAdjustmentMode = .normal
    self.refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    refreshControl?.beginRefreshing()
    
  }
  
  // MARK: - Data Handling
  func dataUpdate() {
    self.pullFratsFromSQLDatabase(types: ["all"])
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.handleRefresh(refreshControl: refreshControl!)
  }
  
  @objc func pullFratsFromSQLDatabase(types : [String]) {
    self.refreshControl?.beginRefreshing()
    DispatchQueue.global(qos: .userInitiated).async {
      var dictArray = [Dictionary<String, Any>()]
      if types.endIndex == 1 && types[0] == "all" {
        if let arr = self.sqlHandler.select(aField: "*", fromTable: "house_info") {
          dictArray = arr
        }
      }
      else {
        var querystring = ""
        for type in types {
          querystring += type + ", "
        }
        querystring = String(querystring.dropLast(2))
        if let arr = self.sqlHandler.select(aField: querystring, fromTable: "house_info") {
          dictArray = arr
        }
      }
      if (dictArray.count != campusSharedInstance.fratNames.count &&
          dictArray.description != self.lastPullDescription ) {
        self.lastPullDescription = dictArray.description
        for dict in dictArray {
            if let name = dict["name"] as? String {
                if campusSharedInstance.fraternities[name] == nil {
                  if let chapter = dict["chapter"] as? String {
                    var previewImage : UIImage?
                    if LOADIMAGES {
                      if let URLString = dict["preview_image"] as? String {
                        if let previewImg = campusSharedInstance.pullImage(fromSource: URLString) {
                          previewImage = previewImg
                        }
                      }
                      else if let URLString = dict["profile_image"] as? String {
                        if let previewImg = campusSharedInstance.pullImage(fromSource: URLString) {
                          previewImage = previewImg
                        }
                      }
                    }
                    let frat = Fraternity(name: name, chapter: chapter, previewImage: previewImage, properties: dict)
                    if LOADIMAGES {
                        if let URLString = dict["cover_image"] as? String {
                          if let coverImg = campusSharedInstance.pullImage(fromSource: URLString) {
                            frat.setProperty(named: "cover_image", to: coverImg)
                          }
                        }
                        if let URLString = dict["profile_image"] as? String {
                          if let coverImg = campusSharedInstance.pullImage(fromSource: URLString) {
                            frat.setProperty(named: "profile_image", to: coverImg)
                          }
                        }
                        if let URLString = dict["calendar_image"] as? String {
                          if let coverImg = campusSharedInstance.pullImage(fromSource: URLString) {
                            frat.setProperty(named: "calendar_image", to: coverImg)
                          }
                        }
                    }
                    campusSharedInstance.fraternities[name] = frat
                    campusSharedInstance.fratNames.append(name)
                    
                  }
              }
          }
        }
      }
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
      }
      
    }
  }
  
  // MARK: - Transitions
  @objc func toggleViewControllers(_:Any?) {
    self.revealViewController().revealToggle(self)
  }
  // Not a very interesting function, makes sure selection from last time
  // is cleared
  // (i.e. it's not highlighted in the dark gray of a selected cell)
  override func viewWillAppear(_ animated: Bool) {
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    if let splitVC = splitViewController {
      clearsSelectionOnViewWillAppear = splitVC.isCollapsed
    }
    super.viewWillAppear(animated)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        var fratName = campusSharedInstance.fratNames[indexPath.row]
        if (viewingFavorites) {
          fratName = campusSharedInstance.favorites[indexPath.row]
        }
        if let object = campusSharedInstance.fraternities[fratName] {
          let controller = (segue.destination as! UINavigationController).topViewController
            as! DetailViewController
          // Send the detail controller the fraternity we're about to display
          controller.selectedFraternity = object
          let _ = campusSharedInstance.getEvents(forFratWithName : fratName)
          // Ensure a back button is given
          controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
          controller.navigationItem.leftBarButtonItem?.tintColor = COLOR_CONST.NAVIGATION_BAR_COLOR
          controller.navigationItem.leftItemsSupplementBackButton = true
        }
      }
        // 3D Touch preview!
      else if let cell = sender as? FratCell {
        // Determine which object user selected
        if let indexPath = tableView.indexPath(for: cell) {
          var fratName = campusSharedInstance.fratNames[indexPath.row]
          if (viewingFavorites) {
            fratName = campusSharedInstance.favorites[indexPath.row]
          }
          if let object = campusSharedInstance.fraternities[fratName] {
            let controller = (segue.destination as! UINavigationController).topViewController
              as! DetailViewController
            controller.selectedFraternity = object
          }
        }
      }
    }
  }
  
  // MARK: - Table View
  
  // Should always be 1 (for now!)
  override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
  
  // Should always be the number of objects to display
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if (viewingFavorites) {
      return campusSharedInstance.favorites.count
    }
    return max(campusSharedInstance.fratNames.count, 1)
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (viewingFavorites) {
      if (campusSharedInstance.favorites.count == 0){
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.text = "No Favorites!"
        cell.textLabel?.textColor = COLOR_CONST.MENU_COLOR
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: "FratCell") as! FratCell
      if let frat = campusSharedInstance.fraternities[campusSharedInstance.favorites[indexPath.row]] {
        cell.titleLabel!.text = frat.name
        cell.subheadingLabel!.text = frat.chapter
        cell.previewImageView!.image = frat.previewImage
      }
      return cell
    }
    else {
      if campusSharedInstance.fratNames.count == 0 {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = NSTextAlignment.center
        if (self.refreshControl!.isRefreshing) {
          cell.textLabel?.text = "Wandering Campus, Looking for Frats..."
        }
        else {
          cell.textLabel?.text = "Pull to Refresh!"
        }
        cell.textLabel?.textColor = COLOR_CONST.MENU_COLOR
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: "FratCell") as! FratCell
      if let frat = campusSharedInstance.fraternities[campusSharedInstance.fratNames[indexPath.row]] {
        cell.titleLabel!.text = frat.name
        cell.subheadingLabel!.text = frat.chapter
        cell.previewImageView!.image = frat.previewImage
      }
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Should only be able to do things to cells if there are actually fraternities represented
    return !campusSharedInstance.fratNames.isEmpty
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    var fratName = ""
    var title = "Favorite"
    var bgColor = COLOR_CONST.MENU_COLOR
    var fratIndex = Int(999)
    if (self.viewingFavorites) {
      fratName = campusSharedInstance.favorites[indexPath.row]
    }
    else {
      fratName = campusSharedInstance.fratNames[indexPath.row]
    }
    if let index = campusSharedInstance.favorites.index(of: fratName) {
      title = "Unfavorite"
      fratIndex = index
      bgColor = bgColor.withAlphaComponent(0.5)
    }
    let toggleFavorite = UITableViewRowAction(style: .normal, title: title, handler: {
      action, cellIndex in
      if (title == "Favorite") {
        campusSharedInstance.favorites.append(fratName)
        action.backgroundColor = COLOR_CONST.MENU_COLOR
      }
      else {
        action.backgroundColor = COLOR_CONST.MENU_COLOR.withAlphaComponent(0.5)
        campusSharedInstance.favorites.remove(at: fratIndex)
        if (self.viewingFavorites) {
          self.tableView.deleteRows(at: [cellIndex], with: UITableViewRowAnimation.left)
        }
        
      }
    })
    toggleFavorite.backgroundColor = bgColor
    
    return [toggleFavorite]
  }
  
  // MARK: - Refresh Control
  @objc func handleRefresh(refreshControl : UIRefreshControl) {
    tableView.reloadData()
    dataUpdate()
  }
}









