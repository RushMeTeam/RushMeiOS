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
class MasterViewController : UITableViewController {
  
  // The hard data used in the table
  var objects = [Any]()
  var fratNames = [String]()
  var fraternities = Dictionary<String, Fraternity>()
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  // MARK: SQL
  let sqlHandler = SQLHandler()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if (!COLOR_CONST.SLIDEOUT_MENU_SHADOW_ENABLED) {
      self.revealViewController().frontViewShadowOpacity = 0
    }
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.alpha = 1
    //navigationController?.navigationBar.backgroundColor = COLOR_CONST.MENU_COLOR
    navigationController?.navigationBar.tintColor = COLOR_CONST.MENU_COLOR
    
    openBarButtonItem.tintColor = COLOR_CONST.MENU_COLOR
    // Ensure the menu button toggles the menu
    openBarButtonItem.target = self
    openBarButtonItem.action = #selector(self.toggleViewControllers(_:))
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: COLOR_CONST.NAVIGATION_BAR_COLOR]
    // Allows for drag to open and tap out to close
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = COLOR_CONST.MENU_COLOR
    refreshControl?.tintAdjustmentMode = .normal
    self.refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    refreshControl?.beginRefreshing()
    
  }
  func dataUpdate() {
    DispatchQueue.global(qos: .userInitiated).async {
      self.pullFromSQLDatabase(types: ["all"])
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
      }
    }
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.handleRefresh(refreshControl: refreshControl!)
  }
  
  @objc func pullFromSQLDatabase(types : [String]) {
    sleep(2) // Simulate loading time
    var dictArray = [Dictionary<String, Any>()]
    if types.endIndex == 1 && types[0] == "all" {
      if let arr = sqlHandler.select(aField: "*", fromTable: "house_info") {
        dictArray = arr
      }
    }
    else {
      var querystring = ""
      for type in types {
        querystring += type + ", "
      }
      querystring = String(querystring.dropLast(2))
      if let arr = sqlHandler.select(aField: querystring, fromTable: "house_info") {
        dictArray = arr
      }
    }
    for dict in dictArray {
      if let name = dict["name"] as? String {
        if let chapter = dict["chapter"] as? String {
          var image : UIImage? = dict["previewImage"] as? UIImage
          if (dict["name"] as! String == "Chi Phi") {
            image = UIImage(named: "chiPhiImage.png")
          }
          let frat = Fraternity(name: name, chapter: chapter, previewImage: image, properties: dict)
          if let _ = image {
            frat.setProperty(named: "coverImage", to: UIImage(named: "rushCalendar.jpg")!)
          }
          fraternities[name] = frat
          fratNames.append(name)
        }
      }
    }
  }
  @objc func toggleViewControllers(_:Any?) {
    self.revealViewController().revealToggle(self)
  }
  // Not a very interesting function, makes sure selection from last time
  // is cleared
  // (i.e. it's not highlighted in the dark gray of a selected cell)
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if segue.identifier == "showDetail" {
        if let indexPath = tableView.indexPathForSelectedRow {
          if let object = fraternities[fratNames[indexPath.row]] {
            let controller = (segue.destination as! UINavigationController).topViewController
                                                                      as! DetailViewController
            // Send the detail controller the fraternity we're about to display
            controller.selectedFraternity = object
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
            if let object = fraternities[fratNames[indexPath.row]] {
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
    return max(fratNames.count, 1)
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if fratNames.count == 0 {
        let cell = UITableViewCell()
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.text = "Pull to Refresh!"
        cell.textLabel?.textColor = COLOR_CONST.MENU_COLOR
        return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "FratCell") as! FratCell
    if let frat = fraternities[fratNames[indexPath.row]] {
      cell.titleLabel!.text = frat.name
      cell.subheadingLabel!.text = frat.chapter
      cell.previewImageView!.image = frat.previewImage
    }
    return cell
  }
  
  @objc func handleRefresh(refreshControl : UIRefreshControl) {
      dataUpdate()
  }
}

