//
//  MasterViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit
import DeviceKit
// Master view controller, a subclass of UITableViewController,
// provides the main list of fraternities from which a user can
// select in order to find detail.
// Notes:
//    -- Allows 3DTouch
//    -- Is the SWRevealViewController's .front view controller
//          -- Set in AppDelegate
// Style guide used: https://swift.org/documentation/api-design-guidelines/

fileprivate let fratCellIdentifier = "FratCell"
fileprivate let segmentCellIdentifier = "SegmentedControlCell"
fileprivate let attractiveFratCellIdentifier = "prettyFratCell"


class MasterViewController : UITableViewController,
                             UISearchBarDelegate,
                             UISearchControllerDelegate,
                             UISearchResultsUpdating{
  // MARK: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating
  func updateSearchResults(for searchController: UISearchController) {
    // As the user types, update the results to match
    self.reloadTableView()
    // Scroll to the top of the table
    self.tableView.scrollToTop(animated: true)
  }
  func willPresentSearchController(_ searchController: UISearchController) {
    // Disable drawer menu swipe while searching
    revealViewController().panGestureRecognizer().isEnabled = false
  }
  func didDismissSearchController(_ searchController: UISearchController) {
    // Enable drawer menu swipe when not searching
    revealViewController().panGestureRecognizer().isEnabled = true
  }
  // Is the lefthand menu extended?
  var drawerExtended : Bool {
    get {
     return revealViewController().frontViewPosition == .right 
    }
  }
  // Is the search bar empty?
  var searchBarIsEmpty : Bool {
    get {
     return searchController.searchBar.text?.isEmpty ?? true 
    }
  }
  // Does the search bar have content, and is it being used to search right now?
  var isSearching : Bool {
    get {
     return searchController.isActive && !searchBarIsEmpty 
    }
  }
  // MARK: Member Variables
  // The hard data used in the table
  let progressView = UIProgressView()
  let searchController = UISearchController.init(searchResultsController: nil)
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  // Is the tableView presenting all fraternities, or just favorites?
  var viewingFavorites : Bool  {
    // Setting viewingFavorites configures the tableView to view the user's favorites
    // NOTE: may be able to set viewingFavorites = true even when there are no 
    //       favorites to view.
    set {
      // TODO: Allow users to set the order of their favorites
      self.tableView.setEditing(false, animated: true)
      self.reloadTableView()
      refreshControl?.isEnabled = !viewingFavorites
      self.favoritesSegmentControl?.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    }
    get {
      return self.favoritesSegmentControl != nil && self.favoritesSegmentControl!.selectedSegmentIndex == 1
    }
  }
  // The last shuffled list of fraternity names
  var shuffledFrats : [String]? = nil {
    willSet {
      if newValue == nil {
       self.reloadTableView()
      }
    }
  }
  // The keys that the tableView uses to display the desired fraternities
  var dataKeys : [String] {
    get {
      // If we're searching, use the contents of the search bar to determine 
      // which fraternities to display
      if isSearching {
        return Array(viewingFavorites ? Campus.shared.favoritedFrats : Campus.shared.fratNames).filter({ (fratName) -> Bool in
          return fratName.lowercased().contains(searchController.searchBar.text!.lowercased())

        }) 
      }
      // Display favorites only
      else if viewingFavorites {
       return Array(Campus.shared.favoritedFrats)
      }
      // Display all fraternities, sorted by name
      else if !RMUserPreferences.shuffleEnabled {
       return Array(Campus.shared.fratNames).sorted()
      }
      // Display all fraternities, shuffled
      else if let _ = shuffledFrats, !self.refreshControl!.isRefreshing {
        return shuffledFrats!
      }
      // Shuffle, then display all fraternities
      else {
        // TODO: Allow no-shuffling option
        shuffledFrats = Campus.shared.fratNames.shuffled()
        return shuffledFrats!
      }
    }
  }
  // The first tableViewCell holds a segmentControl that allows
  // the user to select between all and favorite fraternities
  weak var favoritesSegmentControl : UISegmentedControl?
  // Reload the tableView, with animations
  func reloadTableView() {
    UIView.transition(with: tableView, duration: RMAnimation.ColoringTime/2, options: .transitionCrossDissolve, animations: { 
      self.tableView.reloadData()
    }) { (_) in
      
    }
   //self.tableView.reloadSections(IndexSet.init(integersIn: 0...0), with: .automatic)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    // Set up slideout menu
    if let VC = self.revealViewController().rearViewController as? DrawerMenuViewController {
      VC.masterVC = self.splitViewController
    }
    // Refresh control 
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    self.handleRefresh(refreshControl: refreshControl!)
    // Setup the Search Bar (backend)
    searchController.searchResultsUpdater = self
    searchController.delegate = self
    // Setup the Search Bar (visual)
    navigationController!.hidesBarsOnSwipe = false
    navigationController!.navigationBar.isTranslucent = false
    tableView.tableHeaderView = searchController.searchBar
    searchController.searchBar.isTranslucent = false
    searchController.searchBar.tintColor = RMColor.AppColor
    searchController.searchBar.barTintColor = UIColor.white
    searchController.obscuresBackgroundDuringPresentation = false
    extendedLayoutIncludesOpaqueBars = true
    view.sendSubview(toBack: tableView)
    // Set Search Bar placeholder text, for when a search has not been entered
    searchController.searchBar.placeholder = "Search Fraternities"
    // Set up Navigation bar (visual)
    navigationController!.navigationBar.backgroundColor = UIColor.white
    navigationController!.navigationBar.tintColor = RMColor.AppColor
    navigationController!.navigationBar.barTintColor = UIColor.white//RMColor.AppColor
    navigationController!.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
    definesPresentationContext = true
    // Set up Title View(s) and Progress Bar (visual)
    let wrapperView = UIView()
    let imageView = UIImageView.init(image: RMImage.LogoImage)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = RMColor.AppColor
    imageView.backgroundColor = UIColor.clear
    wrapperView.backgroundColor = UIColor.clear
    wrapperView.clipsToBounds = false
    wrapperView.layer.masksToBounds = false
    imageView.frame.size = CGSize.init(width: 44, height: 32)
    wrapperView.addSubview(imageView)
    var addProgressBar = true
    // TODO: Fix Progress Bar accross all devices!
    let deviceIDs = ["Plus", "5", "SE"]
    for deviceID in deviceIDs {
      if Device().description.contains(deviceID) {
        addProgressBar = false
      }
    }
    if addProgressBar {
      imageView.addSubview(progressView)
    }
    imageView.center = wrapperView.center
    self.navigationItem.titleView = wrapperView
    searchController.hidesNavigationBarDuringPresentation = false
    progressView.frame.size.width = self.view.frame.width
    // The progress view should not be visible less it's loading
    progressView.trackTintColor = UIColor.clear
    progressView.tintColor = navigationController!.navigationBar.tintColor
    // Put the progress view at the bottom of the navigation bar
    progressView.frame.origin.y = wrapperView.frame.maxY + 37//36//UIApplication.shared.statusBarFrame.height//navigationController!.navigationBar.frame.height - progressView.frame.height// //+
    progressView.frame.origin.x = -166
    favoritesSegmentControl?.isEnabled = favoritesSegmentControl!.isEnabled && SQLHandler.shared.isConnected
    
  }
  
  // MARK: - Data Handling
  func dataUpdate() {
    if !self.pullFratsFromSQLDatabase() {
     print("Failed to make SQL Database Connection") 
    }
  }
  // MARK: Data Request
  @objc func pullFratsFromSQLDatabase() -> Bool {
    DispatchQueue.main.async {
      // Reset progress view to indicate loading has commenced
      self.progressView.setProgress(0.05, animated: false)
      self.revealViewController().panGestureRecognizer().isEnabled = false
      self.progressView.alpha = 1
      self.favoritesSegmentControl?.isEnabled = false
      // Reset shuffledFrats
      self.shuffledFrats = nil
    }
    if !SQLHandler.shared.isConnected {
      return false
    }
    // The list of fraternity dictionaries
    var dictArray = [Dictionary<String, Any>()]
    if let arr = SQLHandler.shared.select(fromTable: RMDatabaseKey.FraternityInfoRelation) {
      dictArray = arr
    }
    if dictArray.count > Campus.shared.fratNames.count {
      DispatchQueue.global(qos: .userInitiated).async {
        // Keep track of progress
        var fratCount = 0
        // Iterate through fraternities
        for fraternityDict in dictArray {
          // Initialize the fraternity from a dictionary
          // If successful, register with the shared Campus
          Fraternity.init(fromDict: fraternityDict)?.register(withCampus: Campus.shared)
          fratCount += 1
          DispatchQueue.main.async {            
            // Don't allow refresh during refresh
            self.refreshControl!.isEnabled = false
            // Every other fraternity loaded should be indicated
            if fratCount%2 == 0 {
              self.progressView.setProgress(Float(fratCount+1)/Float(dictArray.count), animated: true)
            }
            if RMUserPreferences.shuffleEnabled && fratCount % 4 == 0 {
              // Every 4 fraternities, update the tableView 
              // (only when in shuffled-- prevents whacky stuttering)
             self.reloadTableView() 
            }
            else if !RMUserPreferences.shuffleEnabled {
              self.reloadTableView()
            }
          }
        }
        DispatchQueue.main.async {
          self.reloadTableView()
          self.favoritesSegmentControl?.isHidden = false
          self.refreshControl!.isEnabled = true
          self.openBarButtonItem.isEnabled = true
          self.favoritesSegmentControl?.isEnabled = true
          self.revealViewController().panGestureRecognizer().isEnabled = true
          // Set the progressView to 100% complete state
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
        self.revealViewController().panGestureRecognizer().isEnabled = false
        self.favoritesSegmentControl?.isEnabled = true
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
  
  
  @IBAction func toggleViewControllers(_ sender: UIBarButtonItem) {
    // If we're searching, cancel the search if we select the menu
    searchController.dismiss(animated: true, completion: nil)
    self.revealViewController().revealToggle(self)
  }
  // MARK: - Transitions
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
          let fratName = self.dataKeys[row]
          SQLHandler.shared.informAction(action: "Fraternity Selected", options: fratName)
          if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
            let controller = (segue.destination as! UINavigationController).topViewController
              as! DetailViewController
            
            // Send the detail controller the fraternity we're about to display
            controller.selectedFraternity = selectedFraternity
            //let _ = Campus.shared.getEvents(forFratWithName : fratName)
          }
        }
        
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
    return dataKeys.count + 1
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: segmentCellIdentifier) as! SegmentCell
      cell.segmentControl.addTarget(self, action: #selector(MasterViewController.segmentControlChanged), for: UIControlEvents.valueChanged)
      cell.segmentControl.isEnabled = Campus.shared.hasFavorites
      favoritesSegmentControl = cell.segmentControl
      return cell
    }
    else if ((viewingFavorites && !Campus.shared.hasFavorites) ||
      !viewingFavorites && Campus.shared.fratNames.count == 0) {
      let cell = UITableViewCell()
      cell.selectionStyle = .none
      cell.textLabel?.textAlignment = NSTextAlignment.center
      cell.textLabel?.text = viewingFavorites ? RMMessage.NoFavorites : ""
      cell.textLabel?.textColor = RMColor.AppColor
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: attractiveFratCellIdentifier) as! AttractiveFratCellTableViewCell
    let fratName = dataKeys[indexPath.row-1]
    if let frat = Campus.shared.fraternitiesDict[fratName]{
      cell.titleLabel?.text = frat.name
      //cell.subheadingLabel?.text = frat.chapter
      cell.previewImageView?.image = frat.previewImage
      cell.isAccentuated = Campus.shared.favoritedFrats.contains(frat.name)
    }
    cell.layoutSubviews()
    return cell
  }
  // Row 0 (segment control cell) should have a height of 36, all others should be 128
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.row == 0 ? 36 : 128
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Can only do the sliding to favorite if using iOS 11 or newer
    // TODO: Decide if slide to favorite is possible in iOS 10.*
    if #available(iOS 11, *) {
     return indexPath.row != 0 && !self.refreshControl!.isRefreshing && Campus.shared.fratNames.count != 0
    }
    else {
      return false
    }
    
  }
  // Swipe to favorite and unfavorite
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let fratName = dataKeys[indexPath.row-1]
    var title = RMMessage.Favorite
    var bgColor = RMColor.AppColor
    if Campus.shared.favoritedFrats.contains(fratName) {
      title = RMMessage.Unfavorite
      bgColor = bgColor.withAlphaComponent(0.5)
    }
    let toggleFavorite = UITableViewRowAction(style: .normal, title: title, handler: {
      action, cellIndex in
      if (title == RMMessage.Favorite) {
        let _ = Campus.shared.getEvents(forFratWithName: fratName, async: true)
        Campus.shared.favoritedFrats.insert(fratName)
        action.backgroundColor = RMColor.AppColor
        if let cell = self.tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
          cell.isAccentuated = true
          SQLHandler.shared.informAction(action: "Fraternity Favorited", options: fratName)
        }
        action.backgroundColor = RMColor.AppColor
      }
      else {
        action.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
        if let cell = self.tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
          cell.isAccentuated = false
          SQLHandler.shared.informAction(action: "Fraternity Unfavorited", options: fratName)
        }
        Campus.shared.favoritedFrats.remove(fratName)
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
// MARK: Array Shuffle
// Source:
//    https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension MutableCollection {
  /// Shuffles the contents of this collection.
  mutating func shuffle() {
    let c = count
    guard c > 1 else { return }
    for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
      let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
      let i = index(firstUnshuffled, offsetBy: d)
      swapAt(firstUnshuffled, i)
    }
  }
}

extension Sequence {
  /// Returns an array with the contents of this sequence, shuffled.
  func shuffled() -> [Element] {
    var result = Array(self)
    result.shuffle()
    return result
  }
} 
extension UIScrollView {
  func scrollToTop(animated : Bool) {
    self.setContentOffset(CGPoint.init(x: 0, y: self.contentInset.top), animated: animated)
  }
}

