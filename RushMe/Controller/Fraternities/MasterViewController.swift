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
UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIViewControllerTransitioningDelegate,
UIGestureRecognizerDelegate{
  
  
//  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//    return PanAnimationController()
//  }
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return PanAnimationController()
  }
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactionController.interactionInProgress ? interactionController : nil
  }
  
  lazy var swipeInteractionController = PanAnimationController()
  lazy var interactionController = PanInteractionController() 
  
  var detailVC : DetailViewController {
    get { 
      return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    }
  }
  
  func getFrat(after : String) -> String? {
    let index = dataKeys.index(of: after)
    return (index != nil && index! < dataKeys.count-1) ? dataKeys[index!+1] : nil
  }
  func getFrat(before : String) -> String? {
    let index = dataKeys.index(of: before)
    return (index != nil && index! > 0) ? dataKeys[index!-1] : nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity?.name,
      let newFrat = getFrat(before: selectedFrat) {
      let newVC = detailVC
      newVC.selectedFraternity = Campus.shared.fraternitiesDict[newFrat]
      return newVC
    }
    return nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity?.name,
      let newFrat = getFrat(after: selectedFrat) {
      let newVC = detailVC
      newVC.selectedFraternity = Campus.shared.fraternitiesDict[newFrat]
      return newVC
    }
    return nil
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed, let fratName = (pageViewController.viewControllers?.first as? DetailViewController)?.selectedFraternity?.name {
      SQLHandler.inform(action: .FraternitySelected, options: fratName) 
      pageViewController.title = fratName.greekLetters
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

  let progressView = UIProgressView()
  let searchController = UISearchController.init(searchResultsController: nil)
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
      else if !RMUserPreferences.shuffleEnabled || Campus.shared.percentageCompletion < 1 {
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
  lazy var favoritesSegmentControl : UISegmentedControl = UISegmentedControl()
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
    _ = self.setupTableHeaderView
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    //self.handleRefresh(refreshControl: refreshControl!)
    
    // Set up Navigation bar (visual)
    // Menu button disabled until refresh complete
    // Ensure the menu button toggles the menu
    // Refresh control 
    refreshControl = UIRefreshControl()
    
    refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)

    //Campus.shared.loadingObservable.addObserver(forOwner: self, handler: handleNewLoading(oldValue:newValue:))
    Campus.shared.percentageCompletionObservable.addObserver(forOwner : self, handler: handlePercentageCompletion(oldValue:newValue:))
    //Campus.shared.fratNamesObservable.addObserver(forOwner: self, handler : handleNewFraternity(oldValue:newValue:))  
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
    if #available(iOS 11, *) {
      //navigationItem.searchController = searchController
    }
    //
    // Set Search Bar placeholder text, for when a search has not been entered
    searchController.searchBar.placeholder = "Search Fraternities"
    //extendedLayoutIncludesOpaqueBars = true
    //definesPresentationContext = true
    //edgesForExtendedLayout = []
    //searchController.searchBar.scopeButtonTitles = []
  }()

  lazy var setupTableHeaderView : Void = {
    _ = setupSearchBar
    let tableHeaderView = UIView()
//    let searchBarView = UIView()
    tableHeaderView.backgroundColor = .white
    searchController.searchBar.backgroundImage = UIImage()
    favoritesSegmentControl.insertSegment(withTitle: "All", at: 0, animated: false)
    favoritesSegmentControl.insertSegment(withTitle: "Favorites", at: 1, animated: false)
    favoritesSegmentControl.selectedSegmentIndex = 0
    favoritesSegmentControl.addTarget(self, action: #selector(MasterViewController.segmentControlChanged), for: UIControlEvents.valueChanged)
    favoritesSegmentControl.translatesAutoresizingMaskIntoConstraints = false
    tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
//    searchBarView.translatesAutoresizingMaskIntoConstraints = false
    tableView.tableHeaderView = tableHeaderView
    //searchBarView.addSubview(searchController.searchBar)
    //tableHeaderView.addSubview(searchBarView)
    tableHeaderView.addSubview(favoritesSegmentControl)
    // TODO: Fix search bar autolayout errors!
    NSLayoutConstraint.activate([tableHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                 tableHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                 tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
//                                 searchBarView.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant : 5),
//                                 searchBarView.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor, constant : -5),
//                                 searchBarView.heightAnchor.constraint(equalToConstant: 44),
//                                 searchBarView.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 0),
//                                 searchBarView.centerXAnchor.constraint(equalTo: tableHeaderView.centerXAnchor),
                                 favoritesSegmentControl.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 4),
                                 favoritesSegmentControl.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant: 6),
                                 favoritesSegmentControl.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor, constant: -6),
                                 favoritesSegmentControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
                                 favoritesSegmentControl.heightAnchor.constraint(lessThanOrEqualToConstant: 28),
                                 tableHeaderView.bottomAnchor.constraint(equalTo: favoritesSegmentControl.bottomAnchor, constant: 4)])
    view.sendSubview(toBack: tableView)
  }()
  
  //lazy var panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(swiped))
//  lazy var setupGestureRecognizers : Void = {
//    tableView.allowsSelection = false
//    
//    let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(double))
//    doubleTap.numberOfTapsRequired = 2
//    doubleTap.numberOfTouchesRequired = 1
//    
//    let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(single))
//    singleTap.numberOfTapsRequired = 1
//    singleTap.numberOfTouchesRequired = 1
//    
//    singleTap.require(toFail: doubleTap)
//    
//    tableView.addGestureRecognizer(doubleTap)
//    tableView.addGestureRecognizer(singleTap)
//    //panGestureRecognizer.delegate = self
//    //tableView.panGestureRecognizer.require(toFail: panGestureRecognizer)
////    tableView.addGestureRecognizer(panGestureRecognizer)
//    //tableView.panGestureRecognizer.addTarget(self, action: #selector(swiped))
//  }()
//  
//  @objc func single(tap : UIGestureRecognizer) {
//    if tap.state == .ended,
//      let indexPath = tableView.indexPathForRow(at: tap.location(in: tap.view)),
//      let cell = tableView.cellForRow(at: indexPath)
//    {
//      interactionController.interactionInProgress = true
//      interactionController.shouldCompleteTransition = true
//      performSegue(withIdentifier: "showDetail", sender: cell) 
//    }
//  }
//  let percentageThreshhold : CGFloat = 0.5
//  var destinationController : UIViewController!
//  @objc func swiped(with pan : UIPanGestureRecognizer) {
//    let translation = pan.translation(in: view)
//    let movement = -translation.x / (view.frame.width)
//    let leftMovement = max(movement, 0)
//    let leftMovementPercent = min(leftMovement, 1)
//    let progress : CGFloat = leftMovementPercent
//    guard let indexPath = tableView.indexPathForRow(at: pan.location(in: pan.view)),
//      let cell = tableView.cellForRow(at: indexPath)
//        else {
//     print("destinationController not set!")
//      return
//    }
//    
//    switch pan.state {
//    case .began:
//      interactionController.interactionInProgress = true
//      // FIX!
//      //present(detailVC, animated: true, completion: nil)
//      performSegue(withIdentifier: "showDetail", sender: indexPath)
//    case .changed:
//      interactionController.shouldCompleteTransition = progress > percentageThreshhold
//      //cell.transform = CGAffineTransform.init(translationX: -progress*view.frame.width/1.5, y: 0)
//      interactionController.update(progress)
//    case .cancelled:
//      interactionController.interactionInProgress = false
//      //self.navigationController?.setToolbarHidden(true, animated: true)
//      interactionController.cancel()
//      cell.transform = CGAffineTransform.identity
//    case .ended:
//      if interactionController.shouldCompleteTransition {
//        //self.navigationController?.setToolbarHidden(false, animated: true)
//        interactionController.finish()
//      } else {
//        //self.navigationController?.setToolbarHidden(true, animated: true)
//        self.interactionController.cancel() 
//        cell.transform = CGAffineTransform.identity
//      }
//    default:
//      break
//    }
//  }
  
  @objc func double(tap : UIGestureRecognizer) {
    if tap.state == .ended, 
      let indexPath = tableView.indexPathForRow(at: tap.location(in: tap.view)),
      let cell = tableView.cellForRow(at: indexPath) as? AttractiveFratCellTableViewCell
    {
      Campus.shared.toggleFavorite(named: dataKeys[indexPath.row])
      cell.isAccentuated = Campus.shared.favoritedFrats.contains(dataKeys[indexPath.row])
      
    }

  }
    
  // MARK: - Data Handling
  func dataUpdate() {
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites 
    shuffledFrats?.shuffle()
    Campus.shared.pullFratsFromSQLDatabase()
    reloadTableView()
  }
  

  
  @IBAction func toggleViewControllers(_ sender: UIBarButtonItem) {
    // If we're searching, cancel the search if we select the menu
    searchController.dismiss(animated: true, completion: nil)
  }
  
  func handlePercentageCompletion(oldValue : Float?, newValue : Float) {
    DispatchQueue.main.async {
      self.searchController.searchBar.placeholder = "Search \(Campus.shared.fratNames.count) Fraternities"
      self.searchController.searchBar.layoutIfNeeded() 
      if newValue != 0 {
       self.refreshControl?.endRefreshing()  
      }
      if newValue == 1 {
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Shuffle Fraternities")
      }
      self.reloadTableView()
    } 
  }
  // MARK: - Transitions
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    if let splitVC = splitViewController {
      clearsSelectionOnViewWillAppear = splitVC.isCollapsed
    }
    //_ = setupGestureRecognizers
    favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites
  }
  @IBAction func unwindToSelf(segue : UIStoryboardSegue) {
    
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
            controller.title = fratName.greekLetters
            controller.dataSource = self
            controller.delegate = self
            controller.view.backgroundColor = .white
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            //navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationItem.hidesBackButton = false
            navigationController?.providesPresentationContextTransitionStyle = true
//            navigationController?.view.backgroundColor = .clear
//            let gradient = CAGradientLayer()
//            let sizeLength = UIScreen.main.bounds.size.height * 2
//            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
//            gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
//            gradient.frame = defaultNavigationBarFrame
//            navigationController?.navigationBar.setBackgroundImage(self.image(fromLayer: gradient), for: .default)
            let dVC = detailVC
            dVC.selectedFraternity = selectedFraternity
            controller.setViewControllers([dVC], direction: .forward, animated: false) { (_) in
//              _ = segue.identifier == "showDetail" ? 
//                      self.navigationController?.setNavigationBarHidden(false, animated: true) 
//                    : nil 
            }
          }
        }
      }
  }
  func image(fromLayer layer: CALayer) -> UIImage {
    UIGraphicsBeginImageContext(layer.frame.size)
    
    layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return outputImage!
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
                          numberOfRowsInSection section: Int) -> Int { return dataKeys.count }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if ((viewingFavorites && !Campus.shared.hasFavorites) ||
      !viewingFavorites && Campus.shared.fratNames.count == 0) {
      let cell = UITableViewCell()
      cell.selectionStyle = .none
      cell.textLabel!.textAlignment = NSTextAlignment.center
      cell.textLabel!.text = viewingFavorites ? RMMessage.NoFavorites : ""
      cell.textLabel!.textColor = RMColor.AppColor
      return cell
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: attractiveFratCellIdentifier) as! AttractiveFratCellTableViewCell
    cell.delegate = self
    let fratName = dataKeys[indexPath.row]
    if let frat = Campus.shared.fraternitiesDict[fratName]{
      cell.titleLabel.text = frat.name
      cell.previewImageView.setImageByURL(fromSource: frat.getProperty(named: RMDatabaseKey.ProfileImageKey) as! String)
      cell.isAccentuated = Campus.shared.favoritedFrats.contains(frat.name)
    }
    return cell
  }
  
  // Row 0 (segment control cell) should have a height of 36, all others should be 128
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 196 //indexPath.row == 0 ? 36 : 128
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

extension UIStoryboard {
  static var main : UIStoryboard {
    get {
     return UIStoryboard.init(name: "Main", bundle: nil) 
    }
  }
}

