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
fileprivate let attractiveFratCellIdentifier = "prettyFratCell"


class MasterViewController : UITableViewController,
                             UISearchBarDelegate {
  
  // MARK: Member Variables
  // The hard data used in the table
  var lastPullDescription = ""
  let attributedStringColor = [NSAttributedStringKey.foregroundColor : RMColor.AppColor]
  let progressView = UIProgressView.init()
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  var viewingFavorites = false {
    didSet {
      self.tableView.setEditing(false, animated: true)
      self.reloadTableView()
      
      refreshControl?.isEnabled = !viewingFavorites
      self.favoritesSegmentControl?.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    }
  }
  weak var favoritesSegmentControl : UISegmentedControl?


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
    SQLHandler.shared.informAction(action: "App Loaded")
    // Remove the default shadow to keep with the simplistic theme
    if (!RMColor.SlideOutMenuShadowIsEnabled) {
      self.revealViewController().frontViewShadowOpacity = 0
    }
    self.revealViewController().rearViewRevealOverdraw = 0
    // Set up slideout menu
    if let VC = self.revealViewController().rearViewController as? DrawerMenuViewController {
      VC.masterVC = self.splitViewController
    }
    revealViewController().rearViewRevealWidth -= 16
    // Make it look good
    //navigationController?.hidesBarsOnSwipe = true
    navigationController!.navigationBar.isTranslucent = false
    navigationController!.navigationBar.backgroundColor = UIColor.white
    navigationController!.navigationBar.tintColor = RMColor.AppColor
    navigationController!.navigationBar.barTintColor = UIColor.white//RMColor.AppColor
    navigationController!.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
    // Menu button disabled until refresh complete
    openBarButtonItem.isEnabled = false
    // Ensure the menu button toggles the menu
    openBarButtonItem.target = self
    openBarButtonItem.action = #selector(self.toggleViewControllers(_:))
    // Refresh control 
    refreshControl = UIRefreshControl()
    refreshControl!.tintAdjustmentMode = .normal
    refreshControl!.tintColor = RMColor.AppColor.withAlphaComponent(0.8)
    refreshControl!.alpha = 0.8
    refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    refreshControl!.beginRefreshing()
    // Add a progress view to indicate loading status
    navigationController!.view.addSubview(progressView)
    progressView.frame = navigationController!.view.frame
    // The progress view should not be visible less it's loading
    progressView.trackTintColor = UIColor.clear
    progressView.tintColor = navigationController!.navigationBar.tintColor
    // Put the progress view at the bottom of the navigation bar
    progressView.frame.origin.y = UIApplication.shared.statusBarFrame.height + 
                                      navigationController!.navigationBar.frame.height - progressView.frame.height
    favoritesSegmentControl?.isEnabled = favoritesSegmentControl!.isEnabled && SQLHandler.shared.isConnected
    self.handleRefresh(refreshControl: refreshControl!)
  }
  
  // MARK: - Data Handling
  func dataUpdate() {
    if !self.pullFratsFromSQLDatabase() {
     print("Failed to load!") 
    }
  }
  // MARK: Data Request
  @objc func pullFratsFromSQLDatabase(types : [String] = []) -> Bool {
    DispatchQueue.main.async {
      // Reset progress view to indicate loading has commenced
      self.progressView.setProgress(0.05, animated: false)
      self.progressView.alpha = 1
      
    }
    if !SQLHandler.shared.isConnected {
      return false
    }
    var dictArray = [Dictionary<String, Any>()]
    if types.count == 0{
        if let arr = SQLHandler.shared.select(fromTable: "house_info") {
          dictArray = arr
        }
    }
    else {
      var querystring = ""
      for type in types {
        querystring += type + ", "
      }
      querystring = String(querystring.dropLast(2))
      if let arr = SQLHandler.shared.select(fromTable: "house_info") {
        dictArray = arr
      }
    }
    if dictArray.count > Campus.shared.fratNames.count {
      DispatchQueue.global(qos: .userInitiated).async {
        // Keep track of progress
        var fratCount = 0
        // Iterate through fraternities
        for fraternityDict in dictArray {
          Fraternity.init(fromDict: fraternityDict)?.register(withCampus: Campus.shared)
          fratCount += 1
          DispatchQueue.main.async {
            self.reloadTableView()
            // Don't allow refresh during refresh
            self.refreshControl!.isEnabled = false
            // Every other fraternity loaded should be indicated
            if fratCount%2 == 0 {
              self.progressView.setProgress(Float(fratCount+1)/Float(dictArray.count), animated: true)
            }
          }
        }
        DispatchQueue.main.async {
          self.reloadTableView()
          self.favoritesSegmentControl?.isHidden = false
          self.refreshControl!.isEnabled = true
          self.openBarButtonItem.isEnabled = true
          
          UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
            self.progressView.progress = 1
            self.progressView.alpha = 0
          }, completion: { (_) in
            self.refreshControl!.endRefreshing()
          })
          
        }
      }
    }
    else {
      // Do a little refresh to indicate a check was made
      // TODO: Make a timing constant for the 0.3
      Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { (timer) in
        self.refreshControl!.endRefreshing()
        self.reloadTableView()
        self.refreshControl!.isEnabled = true
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
          self.progressView.progress = 1
          self.progressView.alpha = 0
        }, completion: { (_) in
        })
      })
    }
    return true
  }
//  let colors  = [UIColor.white, RMColor.AppColor, RMColor.AppColor, UIColor.cyan, UIColor.red] //[UIColor.red, RMColor.AppColor, RMColor.AppColor, UIColor.purple, UIColor.cyan, RMColor.AppColor, RMColor.AppColor, UIColor.orange, RMColor.AppColor, UIColor.magenta, RMColor.AppColor]
//  
//  func animateRefreshView() {
//    struct Counter {
//     static var index = 0
//    }
//    DispatchQueue.main.async {
//      UIView.animate(withDuration: 0.5, animations: {
//        self.refreshControl!.backgroundColor = self.colors[Counter.index%self.colors.count]
//        self.refreshControl!.tintColor = self.colors[(Counter.index%self.colors.count)%self.colors.count]
//      }, completion: { (completed) in
//        Counter.index += 1
//        if self.refreshControl!.isRefreshing {
//          self.animateRefreshView()
//        }
//        else {
//          UIView.animate(withDuration: 0.8, animations: {
//            self.refreshControl!.backgroundColor = UIColor.white
//            self.refreshControl!.tintColor = RMColor.AppColor
//          })
//        }
//      })
//    }
//  }
  
  
  // MARK: - Transitions
  @objc func toggleViewControllers(_:Any?) {
    self.revealViewController().revealToggle(self)
  }
  // Not a very interesting function, makes sure selection from last time
  // is cleared
  // (i.e. it's not highlighted in the dark gray of a selected cell)
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let splitVC = splitViewController {
      clearsSelectionOnViewWillAppear = splitVC.isCollapsed
    }
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    refreshControl?.tintColor = RMColor.AppColor
    favoritesSegmentControl?.isEnabled = Campus.shared.hasFavorites || viewingFavorites
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if let indexPath = tableView.indexPathForSelectedRow {
      // row-1 because first cell is the segment control
      let row = indexPath.row - 1
      if segue.identifier == "showDetail" {
        var fratName = Campus.shared.fratNames[row]
        if (viewingFavorites) {
          fratName = Campus.shared.favoritedFrats[row]
        }
        SQLHandler.shared.informAction(action: "Fraternity Selected", options: fratName)
        if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
          let controller = (segue.destination as! UINavigationController).topViewController
            as! DetailViewController
          // Send the detail controller the fraternity we're about to display
          controller.selectedFraternity = selectedFraternity
          let _ = Campus.shared.getEvents(forFratWithName : fratName)
        }
      }
//      // Determine which object user selected
//      else {
//        var fratName = Campus.shared.fratNames[row]
//        if (viewingFavorites) {
//          fratName = Campus.shared.favoritedFrats[row]
//        }
//        if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
//          let controller = (segue.destination as! UINavigationController).topViewController
//            as! DetailViewController
//          controller.selectedFraternity = selectedFraternity
//        }
//      }
    }
  }
  // Should not perform any segues while refreshing 
  //        or before refresh control is initialized
//  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//    return allowSegues //!(self.refreshControl?.isRefreshing ?? true)
//  }
  @objc func segmentControlChanged(sender : UISegmentedControl) {
    viewingFavorites = (sender.selectedSegmentIndex == 1)
  }
  
  // MARK: - Table View
  
  // Should always be 1 (for now!)
  override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
  
  // Should always be the number of objects to display
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if (viewingFavorites) {
      return Campus.shared.favoritedFrats.count+1
    }
    return Campus.shared.fratNames.count+1
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentedControlCell") as! SegmentCell
      cell.segmentControl.addTarget(self, action: #selector(MasterViewController.segmentControlChanged), for: UIControlEvents.valueChanged)
      cell.segmentControl.isEnabled = Campus.shared.hasFavorites
      favoritesSegmentControl = cell.segmentControl
      return cell
    }
    if ((viewingFavorites && Campus.shared.favoritedFrats.count == 0) || 
      !viewingFavorites && Campus.shared.fratNames.count == 0) {
      let cell = UITableViewCell()
      cell.selectionStyle = .none
      cell.textLabel?.textAlignment = NSTextAlignment.center
      cell.textLabel?.text = viewingFavorites ? RMMessage.NoFavorites : ""
      cell.textLabel?.textColor = RMColor.AppColor
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: attractiveFratCellIdentifier) as! AttractiveFratCellTableViewCell
    let fratName = viewingFavorites ? Campus.shared.favoritedFrats[indexPath.row-1] : Campus.shared.fratNames[indexPath.row-1]
    if let frat = Campus.shared.fraternitiesDict[fratName]{
      cell.titleLabel?.text = frat.name
      cell.subheadingLabel?.text = frat.chapter
      cell.previewImageView?.image = frat.previewImage
      if Campus.shared.favoritedFrats.contains(frat.name) {
        cell.imageBorderColor = RMColor.AppColor.withAlphaComponent(0.7)
      }
      else {
        cell.imageBorderColor = UIColor.clear
      }
    }
    cell.layoutSubviews()
    return cell
  }
  // Row 0 should have a height of 36, all others should be 128
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.row == 0 ? 36 : 128
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Can only do the sliding to favorite if in iOS 11 or up
    // TODO: Decide if slide to favorite is possible in iOS 10.*
    if #available(iOS 11, *) {
     return !self.refreshControl!.isRefreshing && Campus.shared.fratNames.count != 0
    }
    else {
      return false
    }
  }
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let fratName = viewingFavorites ? Campus.shared.favoritedFrats[indexPath.row-1] : Campus.shared.fratNames[indexPath.row-1]
    var title = RMMessage.Favorite
    var bgColor = RMColor.AppColor
    var fratIndex = Int(999)
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
        if let cell = self.tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
          cell.imageBorderColor = RMColor.AppColor.withAlphaComponent(0.7)
          cell.layoutSubviews()
          SQLHandler.shared.informAction(action: "Fraternity Favorited", options: fratName)
        }
        action.backgroundColor = RMColor.AppColor
      }
      else {
        action.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
        if let cell = self.tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
          cell.imageBorderColor = UIColor.white.withAlphaComponent(0.5)
          cell.layoutSubviews()
          SQLHandler.shared.informAction(action: "Fraternity Unfavorited by Swipe", options: fratName)
        }
        Campus.shared.favoritedFrats.remove(at: fratIndex)
        if (self.viewingFavorites) {
          self.tableView.deleteRows(at: [cellIndex], with: UITableViewRowAnimation.left)
        }
        else {
         action.backgroundColor = RMColor.AppColor 
        }
      }
      self.favoritesSegmentControl?.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    })
    toggleFavorite.backgroundColor = bgColor
    return [toggleFavorite]
  }
  
  // MARK: - Refresh Control
  @objc func handleRefresh(refreshControl : UIRefreshControl) {
    dataUpdate()
  }
}
