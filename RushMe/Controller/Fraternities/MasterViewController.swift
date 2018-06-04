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

protocol FraternityCellDelegate {
  func cell(withFratName : String, favoriteStatusToValue : Bool)
}

class MasterViewController : UITableViewController,
UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, FraternityCellDelegate,
UIPageViewControllerDataSource, UIViewControllerTransitioningDelegate,
UIGestureRecognizerDelegate, UIPageViewControllerDelegate{

  func getFrat(after : String) -> String? {
    let index = dataKeys.index(of: after)
    return (index != nil && index! < dataKeys.count-1) ? dataKeys[index!+1] : nil
  }
  func getFrat(before : String) -> String? {
    let index = dataKeys.index(of: before)
    return (index != nil && index! > 0) ? dataKeys[index!-1] : nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity,
      let newFratName = getFrat(before: selectedFrat.name) {
      let newVC = UIStoryboard.main.detailVC
      newVC.title = newFratName
      newVC.selectedFraternity = Campus.shared.fraternitiesDict[newFratName]
      return newVC
    }
    return nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity?.name,
      let newFratName = getFrat(after: selectedFrat) {
      let newVC = UIStoryboard.main.detailVC
      newVC.title = newFratName
      newVC.selectedFraternity = Campus.shared.fraternitiesDict[newFratName]
      return newVC
    }
    return nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed, let vc = pageViewController.viewControllers?.first as? DetailViewController,
      let frat = vc.selectedFraternity {
      pageViewController.navigationItem.setRightBarButton(barButtonItem(for: frat), animated: false)
      pageViewController.title = frat.name.greekLetters
    }
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return dataKeys.count
  }
  func barButtonItem(for frat : Fraternity) -> UIBarButtonItem {
    let button = UIBarButtonItem(image: Campus.shared.favoritedFrats.contains(frat.name) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")  , style: .plain, target: self, action: #selector(MasterViewController.toggleFavorite(sender:)))
    button.title = frat.name
    return button
  }
  @objc func toggleFavorite(sender : UIBarButtonItem) {
    if let fratName = sender.title {
      sender.image = Campus.shared.toggleFavorite(named: fratName) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")
      tableView.reloadRows(at: [IndexPath.init(row: dataKeys.index(of: fratName)!, section: 0)], with: .automatic)
    }
  }
  // MARK: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating
  func updateSearchResults(for searchController: UISearchController) {
    // As the user types, update the results to match
    self.reloadTableView()
    // Scroll to the top of the table
    self.tableView.scrollToTop(animated: true)
  }
  func willPresentSearchController(_ searchController: UISearchController) {
    // Disable drawer menu swipe while searching
    //revealViewController().panGestureRecognizer().isEnabled = false
  }
  func didDismissSearchController(_ searchController: UISearchController) {
    // Enable drawer menu swipe when not searching
    //revealViewController().panGestureRecognizer().isEnabled = true
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
  lazy private(set) var searchController = UISearchController(searchResultsController: nil)
  // The menu button used to toggle the slide-out menu
  //@IBOutlet var openBarButtonItem: UIBarButtonItem!
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
      self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    }
    get {
      return favoritesSegmentControl.selectedSegmentIndex == 1
    }
  }
  
  // The last shuffled list of fraternity names
  var shuffledFrats : [String]? = nil
  // The keys that the tableView uses to display the desired fraternities
  var dataKeys : [String] {
    get {
      // FOR SCREENSHOTS 
//      if !viewingFavorites {
//       return ["Theta Chi", "Chi Phi", "Phi Iota Alpha", "Rensselaer Society of Engineers", "Psi Upsilon", "Delta Tau Delta",  "Zeta Psi", "Delta Phi", "Pi Lambda Phi","Theta Xi",  "Phi Kappa Theta", "Sigma Alpha Epsilon", "Phi Sigma Kappa", "Sigma Phi Epsilon", "Delta Kappa Epsilon", "Pi Kappa Alpha", "Lambda Chi Alpha", "Alpha Phi Alpha", "Pi Kappa Phi", "Acacia", "Phi Mu Delta", "Tau Kappa Epsilon", "Alpha Epsilon Pi", "Phi Gamma Delta", "Alpha Sigma Phi", "Tau Epsilon Phi", "Alpha Chi Rho", "Sigma Chi", "Pi Delta Psi"]
//      }
      
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
      else if !RushMe.shuffleEnabled || Campus.shared.percentageCompletion < 1 {
        return Array(Campus.shared.fratNames).sorted()
      }
      // Display all fraternities, shuffled
      else if let _ = shuffledFrats {
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
  lazy var favoritesSegmentControl = UISegmentedControl()
  // Reload the tableView, with animations
  func reloadTableView() {
    DispatchQueue.main.async {
      UIView.transition(with: self.tableView, duration: RMAnimation.ColoringTime/2, options: .transitionCrossDissolve, animations: { 
        self.tableView.reloadData()
      }) { (_) in
      }
    }
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = self.setupTableHeaderView
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController!.navigationBar.shadowImage = UIImage()
    
    // Set up Navigation bar (visual)
    // Menu button disabled until refresh complete
    // Ensure the menu button toggles the menu
    // Refresh control 
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    tableView.backgroundView = refreshControl
    
    refreshControl!.backgroundColor = RMColor.AppColor
    refreshControl!.tintColor = .white
    
    Campus.shared.percentageCompletionObservable.addObserver(forOwner : self, handler: handlePercentageCompletion(oldValue:newValue:))
  }

  lazy var setupSearchBar : Void = {
    // Setup the Search Bar (backend)
  
    searchController.searchResultsUpdater = self
    searchController.delegate = self
    // Setup the Search Bar (visual)
    //searchController.searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    searchController.searchBar.isTranslucent = false
    searchController.searchBar.tintColor = RMColor.AppColor
    searchController.searchBar.barTintColor = UIColor.white
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    
    //
    // Set Search Bar placeholder text, for when a search has not been entered
    searchController.searchBar.placeholder = "Search Fraternities"
    //extendedLayoutIncludesOpaqueBars = true
    //definesPresentationContext = true
    //edgesForExtendedLayout = []
    //searchController.searchBar.scopeButtonTitles = []
    //                                 searchBarView.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant : 5),
    //                                 searchBarView.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor, constant : -5),
    //                                 searchBarView.heightAnchor.constraint(equalToConstant: 44),
    //                                 searchBarView.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 0),
    //                                 searchBarView.centerXAnchor.constraint(equalTo: tableHeaderView.centerXAnchor),
    //    searchBarView.translatesAutoresizingMaskIntoConstraints = false
    //    let searchBarView = UIView()
       searchController.searchBar.backgroundImage = UIImage()
    
    //searchBarView.addSubview(searchController.searchBar)
    //tableHeaderView.addSubview(searchBarView)
  }()

  lazy var setupTableHeaderView : Void = {
    _ = setupSearchBar
    let tableHeaderView = UIView()
    
    tableHeaderView.backgroundColor = RMColor.AppColor
//    tableView.backgroundColor = RMColor.AppColor
    favoritesSegmentControl.insertSegment(withTitle: "All", at: 0, animated: false)
    favoritesSegmentControl.insertSegment(withTitle: "Favorites", at: 1, animated: false)
    favoritesSegmentControl.selectedSegmentIndex = 0
    favoritesSegmentControl.tintColor = .white
    favoritesSegmentControl.addTarget(self, action: #selector(MasterViewController.segmentControlChanged), for: UIControlEvents.valueChanged)
    favoritesSegmentControl.translatesAutoresizingMaskIntoConstraints = false
    tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
    //view.backgroundColor = RMColor.AppColor
    tableView.tableHeaderView = tableHeaderView
    
    tableHeaderView.addSubview(favoritesSegmentControl)
    // TODO: Fix search bar autolayout errors!
    NSLayoutConstraint.activate([tableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor),
                                 tableHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                 tableHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                 tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
                                 favoritesSegmentControl.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 6),
                                 favoritesSegmentControl.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant: 7),
                                 favoritesSegmentControl.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor, constant: -7),
                                 favoritesSegmentControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
                                 favoritesSegmentControl.heightAnchor.constraint(lessThanOrEqualToConstant: 28),
                                 tableHeaderView.bottomAnchor.constraint(equalTo: favoritesSegmentControl.bottomAnchor, constant: 6)])
  }()
    
  // MARK: - Data Handling
  func dataUpdate() {
    shuffledFrats?.shuffle()
    Campus.shared.pullFratsFromSQLDatabase()
    reloadTableView()
  }
  


  
  func handlePercentageCompletion(oldValue : Float?, newValue : Float) {
    DispatchQueue.main.async {
      self.searchController.searchBar.placeholder = "Search \(Campus.shared.fratNames.count) Fraternities"
      self.searchController.searchBar.layoutIfNeeded() 
      if newValue != 0 {
       self.refreshControl?.endRefreshing()  
      }
      if newValue == 1 {
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Shuffle Fraternities", attributes : [NSAttributedStringKey.foregroundColor: UIColor.white])
        self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
      }
      self.reloadTableView()
    } 
  }
  
  // MARK: - Transitions
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let splitVC = splitViewController {
      clearsSelectionOnViewWillAppear = splitVC.isCollapsed
    }
    //_ = setupGestureRecognizers
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if segue.identifier == "showDetail" || segue.identifier == "peekDetail" {
      let cell = sender as? UITableViewCell ?? UITableViewCell()
      if let row = (sender as? IndexPath)?.row ?? tableView.indexPathsForSelectedRows?.first?.row ?? tableView.indexPath(for: cell)?.row { 
          let fratName = self.dataKeys[row]
          if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
            SQLHandler.inform(action: .FraternitySelected, options: fratName)
            let controller = segue.destination as! UIPageViewController
            controller.navigationItem.setRightBarButton(barButtonItem(for: selectedFraternity), animated: false)
            controller.title = fratName.greekLetters
            controller.dataSource = self
            controller.delegate = self
            controller.view.backgroundColor = .white
            let dVC = UIStoryboard.main.detailVC
            dVC.selectedFraternity = selectedFraternity
            controller.setViewControllers([dVC], direction: .forward, animated: false)
          }
        }
      }
  }
  // Should not perform any segues while refreshing 
  //        or before refresh control is initialized
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
      return !(self.refreshControl?.isRefreshing ?? true)
    }
  
  @objc func segmentControlChanged(sender : UISegmentedControl) {
    viewingFavorites = (sender.selectedSegmentIndex == 1)
  }
  // MARK: FraternityCellDelegate
  func cell(withFratName fratName: String, favoriteStatusToValue isFavorited : Bool) {
    guard Campus.shared.fratNames.contains(fratName) else {
     return 
    }
    if isFavorited {
      Campus.shared.addFavorite(named: fratName) 
    }
    else {
      Campus.shared.removeFavorite(named: fratName)
    }
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites
  }

  
  // MARK: - Table View
  
  // Should always be 1 (for now!)
  override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
  
  // Should always be the number of objects to display
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int { return max(dataKeys.count, 1) }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if dataKeys.count == 0{
      let cell = UITableViewCell()
      cell.selectionStyle = .none
      cell.textLabel!.textAlignment = NSTextAlignment.center
      cell.textLabel!.numberOfLines = 2
      if !Campus.shared.isLoading {
        cell.textLabel!.text = viewingFavorites ? RMMessage.NoFavorites : "Something went wrong...\nTry again."
      }
      cell.textLabel!.textColor = RMColor.AppColor
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: attractiveFratCellIdentifier) as! AttractiveFratCellTableViewCell
    cell.delegate = self
    guard indexPath.row < dataKeys.count else {
      tableView.reloadData()
      return cell
    }
    cell.fraternity = Campus.shared.fraternitiesDict[dataKeys[indexPath.row]]
      cell.loadImage()
    
    return cell
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 196
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }

  func setFavorite(withAction action : UITableViewRowAction, forCell cellIndex : IndexPath, forFrat fratName : String) {
    if (action.title == RMMessage.Favorite) {
      let _ = Campus.shared.getEvents(forFratWithName: fratName, async: true)
      Campus.shared.addFavorite(named: fratName)
      action.backgroundColor = RMColor.AppColor
      if let cell = tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
        cell.isAccentuated = true
        //SQLHandler.shared.informAction(action: "Fraternity Favorited", options: fratName)
      }
      action.backgroundColor = RMColor.AppColor
      tableView.reloadRows(at: [cellIndex], with: .automatic)
    }
    else {
      action.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
      if let cell = tableView.cellForRow(at: cellIndex) as? AttractiveFratCellTableViewCell {
        cell.isAccentuated = false
        //SQLHandler.shared.informAction(action: "Fraternity Unfavorited", options: fratName)
      }
      Campus.shared.removeFavorite(named: fratName)
      if (viewingFavorites) {
        tableView.deleteRows(at: [cellIndex], with: UITableViewRowAnimation.left)
      }
      else {
        action.backgroundColor = RMColor.AppColor
        tableView.reloadRows(at: [cellIndex], with: .right)
      }
    }
    self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
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
      let d : Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
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





