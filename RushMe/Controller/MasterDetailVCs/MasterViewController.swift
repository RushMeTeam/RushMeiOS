//
//  MasterViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit
// Master view controller, a subclass of UITableViewController,
// provides the main list of fraternities from which a user can
// select in order to find detail.
// Notes:
//    -- Allows 3DTouch
//    -- Is the SWRevealViewController's .front view controller
//          -- Set in AppDelegate
// Style guide used: https://swift.org/documentation/api-design-guidelines/
let LOADIMAGES = true

fileprivate let fratCellIdentifier = "FratCell"

class MasterViewController : UITableViewController {
  
  // The hard data used in the table
  var lastPullDescription = ""
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  var viewingFavorites = false
  @IBOutlet weak var favoritesBarButton: UIBarButtonItem!
  
  @IBAction func favoritesToggled(_ sender: UIBarButtonItem) {
    if (refreshControl!.isRefreshing) {
      return
    }
    viewingFavorites = !viewingFavorites
    if !viewingFavorites { favoritesBarButton.image = RMImage.FavoritesImageUnfilled }
    else { favoritesBarButton.image = RMImage.FavoritesImageFilled }
    
    refreshControl?.isEnabled = !viewingFavorites
    self.favoritesBarButton.isEnabled = !Campus.shared.favoritedFrats.isEmpty || self.viewingFavorites
    //self.tableView.reloadData()
    self.reloadTableView()
  }
  func reloadTableView() {
    UIView.transition(with: tableView,
                      duration: RMAnimation.ColoringTime/2,
                      options: UIViewAnimationOptions.transitionCrossDissolve,
                      animations: { self.tableView.reloadData() })
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = RMMessage.AppName
    // Remove the default shadow to keep with the simplistic theme
    if (!RMColor.SlideOutMenuShadowIsEnabled) {
      self.revealViewController().frontViewShadowOpacity = 0
    }
    // Set up slideout menu
    if let VC = self.revealViewController().rearViewController as? DrawerMenuViewController {
      VC.masterVC = self.splitViewController
    }
    // Make it look good
    //navigationController?.navigationBar.alpha = 0.2
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    navigationController?.navigationBar.tintColor = RMColor.AppColor
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    
    openBarButtonItem.tintColor = RMColor.AppColor
    // Ensure the menu button toggles the menu
    openBarButtonItem.target = self
    openBarButtonItem.action = #selector(self.toggleViewControllers(_:))
    
    // Allows for drag to open and tap out to close
    
    
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = RMColor.AppColor
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
      if types.count == 1 && types[0] == "all" {
        if let arr = sharedSQLHandler.select(aField: "*", fromTable: "house_info") {
          dictArray = arr
        }
      }
      else {
        var querystring = ""
        for type in types {
          querystring += type + ", "
        }
        querystring = String(querystring.dropLast(2))
        if let arr = sharedSQLHandler .select(aField: querystring, fromTable: "house_info") {
          dictArray = arr
        }
      }
      if (dictArray.count != Campus.shared.fratNames.count &&
        dictArray.description != self.lastPullDescription ) {
        self.lastPullDescription = dictArray.description
        for dict in dictArray {
          if let name = dict[RMDatabaseKey.NameKey] as? String {
            if Campus.shared.fraternitiesDict[name] == nil {
              if let chapter = dict[RMDatabaseKey.ChapterKey] as? String {
                var previewImage : UIImage?
                var profileImage : UIImage?
                if LOADIMAGES {
                  // Get the PreviewImage
                  if let URLString = dict[RMDatabaseKey.PreviewImageKey] as? String {
                    if let previewImg = Campus.shared.pullImage(fromSource: URLString) {
                      previewImage = previewImg
                    }
                  }
                    // Get the ProfileImage
                  else if let URLString = dict[RMDatabaseKey.ProfileImageKey] as? String {
                    if let previewImg = Campus.shared.pullImage(fromSource: URLString) {
                      previewImage = previewImg
                      profileImage = previewImg
                    }
                  }
                }
                let frat = Fraternity(name: name, chapter: chapter, previewImage: previewImage, properties: dict)
                if LOADIMAGES {
                  if let _ = profileImage {
                    frat.setProperty(named: RMDatabaseKey.ProfileImageKey, to: profileImage!)
                  }
                  else {
                    frat.setProperty(named: RMDatabaseKey.ProfileImageKey, to: RMImage.NoImage)
                  }
                  
                  // Get the CoverImage
                  if let URLString = dict[RMDatabaseKey.CoverImageKey] as? String {
                    if let coverImg = Campus.shared.pullImage(fromSource: URLString) {
                      frat.setProperty(named: RMDatabaseKey.CoverImageKey, to: coverImg)
                    }
                  }
                  if let URLString = dict[RMDatabaseKey.CalendarImageKey] as? String {
                    if let calendarImg = Campus.shared.pullImage(fromSource: URLString) {
                      frat.setProperty(named: RMDatabaseKey.CalendarImageKey, to: calendarImg)
                    }
                  }
                  
                }
                Campus.shared.fraternitiesDict[name] = frat
                Campus.shared.fratNames.append(name)
                
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
    self.favoritesBarButton.isEnabled = !Campus.shared.favoritedFrats.isEmpty || self.viewingFavorites
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        var fratName = Campus.shared.fratNames[indexPath.row]
        if (viewingFavorites) {
          fratName = Campus.shared.favoritedFrats[indexPath.row]
        }
        if let object = Campus.shared.fraternitiesDict[fratName] {
          let controller = (segue.destination as! UINavigationController).topViewController
            as! DetailViewController
          // Send the detail controller the fraternity we're about to display
          controller.selectedFraternity = object
          let _ = Campus.shared.getEvents(forFratWithName : fratName)
          // Ensure a back button is given
          controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
          controller.navigationItem.leftBarButtonItem?.tintColor = RMColor.NavigationItemsColor
          controller.navigationItem.leftItemsSupplementBackButton = true
        }
      }
        // 3D Touch preview!
      else if let cell = sender as? FratCell {
        // Determine which object user selected
        if let indexPath = tableView.indexPath(for: cell) {
          var fratName = Campus.shared.fratNames[indexPath.row]
          if (viewingFavorites) {
            fratName = Campus.shared.favoritedFrats[indexPath.row]
          }
          if let object = Campus.shared.fraternitiesDict[fratName] {
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
      return Campus.shared.favoritedFrats.count
    }
    return max(Campus.shared.fratNames.count, 1)
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (viewingFavorites) {
      if (Campus.shared.favoritedFrats.count == 0){
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.text = RMMessage.NoFavorites
        cell.textLabel?.textColor = RMColor.AppColor
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: fratCellIdentifier) as! FratCell
      if let frat = Campus.shared.fraternitiesDict[Campus.shared.favoritedFrats[indexPath.row]] {
        cell.titleLabel!.text = frat.name
        cell.subheadingLabel!.text = frat.chapter
        cell.previewImageView!.image = frat.previewImage
      }
      cell.imageBorderColor = RMColor.AppColor.withAlphaComponent(0.7)
      return cell
    }
    else {
      if Campus.shared.fratNames.count == 0 {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.textAlignment = NSTextAlignment.center
        if (self.refreshControl!.isRefreshing) {
          cell.textLabel?.text = RMMessage.LoadingFrats
        }
        else {
          cell.textLabel?.text = RMMessage.Refresh
        }
        cell.textLabel?.textColor = RMColor.AppColor
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: fratCellIdentifier) as! FratCell
      if let frat = Campus.shared.fraternitiesDict[Campus.shared.fratNames[indexPath.row]] {
        cell.titleLabel!.text = frat.name
        cell.subheadingLabel!.text = frat.chapter
        cell.previewImageView!.image = frat.previewImage
        if Campus.shared.favoritedFrats.contains(frat.name) {
          cell.imageBorderColor = RMColor.AppColor.withAlphaComponent(0.7)
        }
        else {
          cell.imageBorderColor = UIColor.white.withAlphaComponent(0.5)
        }
      }
      
      
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Should only be able to do things to cells if there are actually fraternities represented
    return !Campus.shared.fratNames.isEmpty
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    var fratName = ""
    var title =  RMMessage.Favorite
    var bgColor = RMColor.AppColor
    var fratIndex = Int(999)
    if (self.viewingFavorites) {
      fratName = Campus.shared.favoritedFrats[indexPath.row]
    }
    else {
      fratName = Campus.shared.fratNames[indexPath.row]
    }
    if let index = Campus.shared.favoritedFrats.index(of: fratName) {
      title = RMMessage.Unfavorite
      fratIndex = index
      bgColor = bgColor.withAlphaComponent(0.5)
    }
    let toggleFavorite = UITableViewRowAction(style: .normal, title: title, handler: {
      action, cellIndex in
      if (title == RMMessage.Favorite) {
        let _ = Campus.shared.getEvents(forFratWithName: fratName, async: true)
        Campus.shared.favoritedFrats.append(fratName)
        action.backgroundColor = RMColor.AppColor
        if let cell = self.tableView.cellForRow(at: cellIndex) as? FratCell {
            cell.imageBorderColor = RMColor.AppColor.withAlphaComponent(0.7)        }
      }
      else {
        action.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
        if let cell = self.tableView.cellForRow(at: cellIndex) as? FratCell {
          cell.imageBorderColor = UIColor.white.withAlphaComponent(0.5)
        }
        Campus.shared.favoritedFrats.remove(at: fratIndex)
        if (self.viewingFavorites) {
          self.tableView.deleteRows(at: [cellIndex], with: UITableViewRowAnimation.left)
        }
        
      }
      
      self.favoritesBarButton.isEnabled = !Campus.shared.favoritedFrats.isEmpty || self.viewingFavorites
    })
    toggleFavorite.backgroundColor = bgColor
    return [toggleFavorite]
  }
  
  // MARK: - Refresh Control
  @objc func handleRefresh(refreshControl : UIRefreshControl) {
    dataUpdate()
  }
}









