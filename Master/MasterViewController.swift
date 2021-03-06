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

fileprivate let fratCellIdentifier = "FratCell"
fileprivate let segmentCellIdentifier = "SegmentedControlCell"
fileprivate let attractiveFratCellIdentifier = "prettyFratCell"

protocol FraternityCellDelegate {
    func cell(withFratName : String, favoriteStatusToValue : Bool)
}

class MasterViewController : UITableViewController,
    UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, FraternityCellDelegate,
    UIPageViewControllerDataSource, UIViewControllerTransitioningDelegate,
UIGestureRecognizerDelegate, UIPageViewControllerDelegate {
    
    
    @objc func toggleFavorite(sender : UIBarButtonItem) {
        if let fratName = sender.title, let frat = Campus.shared.fraternitiesByName[fratName] {
            sender.image = Campus.shared.toggleFavorite(frat: frat) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")
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
            // For Screenshots
            //      if !viewingFavorites {
            //       return ["Theta Chi", "Chi Phi", "Phi Iota Alpha", "Rensselaer Society of Engineers",
            //         "Psi Upsilon", "Delta Tau Delta",  "Zeta Psi", "Delta Phi", "Pi Lambda Phi","Theta Xi",
            //         "Phi Kappa Theta", "Sigma Alpha Epsilon", "Phi Sigma Kappa", "Sigma Phi Epsilon", "Delta Kappa Epsilon",
            //         "Pi Kappa Alpha", "Lambda Chi Alpha", "Alpha Phi Alpha", "Pi Kappa Phi", "Acacia", "Phi Mu Delta",
            //         "Tau Kappa Epsilon", "Alpha Epsilon Pi", "Phi Gamma Delta", "Alpha Sigma Phi", "Tau Epsilon Phi",
            //         "Alpha Chi Rho", "Sigma Chi", "Pi Delta Psi"]
            //      }
            
            // If we're searching, use the contents of the search bar to determine
            // which fraternities to display
            if isSearching {
              return viewingFavorites ? User.session.favoriteFrats.map({ (frat) -> String in
                return frat.name
              }) : Array(Campus.shared.fraternityNames).filter({ (fratName) -> Bool in
                    return fratName.lowercased().contains(searchController.searchBar.text!.lowercased())
                })
            }
                // Display favorites only
            else if viewingFavorites {
              return User.session.favoriteFrats.map({ (frat) -> String in
                return frat.name
              })
            }
                // Display all fraternities, sorted by name
            else if !User.preferences.shuffleEnabled || Campus.shared.percentageCompletion < 1 {
                return Array(Campus.shared.fraternityNames).sorted()
            }
                // Display all fraternities, shuffled
            else if let _ = shuffledFrats {
                return shuffledFrats!
            }
                // Shuffle, then display all fraternities
            else {
                shuffledFrats = Campus.shared.fraternityNames.shuffled()
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
            UIView.transition(with: self.tableView, duration: Frontend.animations.defaultDuration/2, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }) { (_) in
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = setupTableHeaderView
        _ = setupSearchBar
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
        refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.backgroundView = refreshControl
        
        refreshControl!.backgroundColor = Frontend.colors.RefreshControlBackgroundColor
        refreshControl!.tintColor = Frontend.colors.RefreshControlTintColor
    }
    
    lazy var setupSearchBar : Void = {
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        // Setup the Search Bar (visual)
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.backgroundColor = Frontend.colors.SearchBarBackgroundColor
        searchController.searchBar.barTintColor = Frontend.colors.SearchBarBackgroundColor
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        // set Search Bar placeholder text, for when a search has not been entered
        searchController.searchBar.placeholder = "Search Fraternities"
        
        searchController.searchBar.backgroundImage = UIImage()
        tableView.tableHeaderView = searchController.searchBar
    }()
    var tableHeaderView : UIView!
    lazy var setupTableHeaderView : Void = {
        tableHeaderView = UIView()
        
        tableHeaderView.backgroundColor = Frontend.colors.NavigationBarColor
        favoritesSegmentControl.insertSegment(withTitle: "All", at: 0, animated: false)
        favoritesSegmentControl.insertSegment(withTitle: "Favorites", at: 1, animated: false)
        favoritesSegmentControl.selectedSegmentIndex = 0
        favoritesSegmentControl.tintColor = Frontend.colors.NavigationBarTintColor
        favoritesSegmentControl.addTarget(self, action: #selector(MasterViewController.segmentControlChanged), for: UIControl.Event.valueChanged)
        favoritesSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        tableHeaderView.addSubview(favoritesSegmentControl)
        // TODO: Fix search bar autolayout errors!
        NSLayoutConstraint.activate([favoritesSegmentControl.topAnchor.constraint(equalTo: tableHeaderView.topAnchor, constant: 6),
                                     favoritesSegmentControl.leftAnchor.constraint(equalTo: tableHeaderView.leftAnchor, constant: 7),
                                     favoritesSegmentControl.rightAnchor.constraint(equalTo: tableHeaderView.rightAnchor, constant: -7),
                                     favoritesSegmentControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
                                     favoritesSegmentControl.heightAnchor.constraint(lessThanOrEqualToConstant: 28),
                                     tableHeaderView.bottomAnchor.constraint(equalTo: favoritesSegmentControl.bottomAnchor, constant: 6)])
    }()
    
    // MARK: - Data Handling
    func dataUpdate() {
        shuffledFrats?.shuffle()
        Campus.shared.pullFromBackend()
        reloadTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Campus.shared.hasFavorites || viewingFavorites ? 40  : 0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        _ = setupTableHeaderView
        return tableHeaderView
    }
    
    func updateSearchBar() {
        self.searchController.searchBar.placeholder = "Search \(Campus.shared.fraternityNames.count) Fraternities"
        self.searchController.searchBar.layoutIfNeeded()
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Shuffle Fraternities",
                                                                       attributes : [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    }
    
    func handlePercentageCompletion(oldValue : Float?, newValue progress : Float) {
        DispatchQueue.main.async {
            self.reloadTableView()
            self.updateSearchBar()
            if progress == 1 {
                self.endRefreshing()
            }
        }
    }
    
    // MARK: - Transitions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Campus.shared.percentageCompletionObservable.addObserver(forOwner : self,
                                                                 handler: handlePercentageCompletion(oldValue:newValue:))
        favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail" || segue.identifier == "peekDetail",
            let cell = sender as? FraternityTableViewCell,
            let frat = cell.fraternity else {
                print("Cannot obtain cell fraternity...")
                return
        }
        
        // Checks if segue is going into detail
        Backend.log(action: .Selected(fraternity: frat))
        let controller = segue.destination as! UIPageViewController
        controller.navigationItem.setRightBarButton(barButtonItem(for: frat), animated: false)
        controller.title = frat.name.greekLetters
        controller.dataSource = self
        controller.delegate = self
        controller.view.backgroundColor = .white
        let dVC = UIStoryboard.main.detailVC
        dVC.selectedFraternity = frat
        controller.setViewControllers([dVC], direction: .forward, animated: false)
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
        guard let frat = Campus.shared.fraternitiesByName[fratName] else {
            return
        }
        
        _ = Campus.shared.toggleFavorite(frat: frat)
        if (!Campus.shared.hasFavorites) {
            reloadTableView()
        }
        favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || viewingFavorites
    }
    
    
    // MARK: - Table View
    
    
    
    // Should always be the number of objects to display
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return max(dataKeys.count, 1)
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataKeys.count == 0 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel!.textAlignment = NSTextAlignment.center
            cell.textLabel!.textColor = Frontend.colors.AppColor
            cell.textLabel!.numberOfLines = 2
            
            let server_status = Backend.serverStatus()
            if(viewingFavorites && searchBarIsEmpty) {
                cell.textLabel!.text = "You don't have any favorites."
            } else if (!searchBarIsEmpty) {
                cell.textLabel!.text = "No results. Try a different search."
            } else {
                if(server_status != "operational") {
                    cell.textLabel!.text = server_status
                }
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: attractiveFratCellIdentifier) as! FraternityTableViewCell
        cell.delegate = self
        guard indexPath.row < dataKeys.count else {
            tableView.reloadData()
            return cell
        }
        cell.fraternity = Campus.shared.fraternitiesByName[dataKeys[indexPath.row]]
        cell.loadImage()
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func setFavorite(withAction action : UITableViewRowAction, forCell cellIndex : IndexPath, forFrat fratName : String) {
      guard let frat = Campus.shared.fraternitiesByName[fratName] else {
       return 
      }
        if (action.title == Frontend.text.favorite) {
            _ = Campus.shared.favorite(frat: frat)
            action.backgroundColor = Frontend.colors.AppColor
            if let cell = tableView.cellForRow(at: cellIndex) as? FraternityTableViewCell {
                cell.isAccentuated = true
            }
            action.backgroundColor = Frontend.colors.AppColor
            tableView.reloadRows(at: [cellIndex], with: .automatic)
        }
        else {
            action.backgroundColor = Frontend.colors.AppColor.withAlphaComponent(0.5)
            if let cell = tableView.cellForRow(at: cellIndex) as? FraternityTableViewCell {
                cell.isAccentuated = false
                //SQLHandler.shared.informAction(action: "Fraternity Unfavorited", options: fratName)
            }
            _ = Campus.shared.unfavorite(frat: frat)
            if (viewingFavorites) {
                tableView.deleteRows(at: [cellIndex], with: UITableView.RowAnimation.left)
            }
            else {
                action.backgroundColor = Frontend.colors.AppColor
                tableView.reloadRows(at: [cellIndex], with: .right)
            }
        }
        self.favoritesSegmentControl.isEnabled = Campus.shared.hasFavorites || self.viewingFavorites
    }
    
    // MARK: - Refresh Control
    @objc func handleRefresh(refreshControl : UIRefreshControl) {
        dataUpdate()
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
        if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity,
            let newFratName = getFrat(before: selectedFrat.name) {
            let newVC = UIStoryboard.main.detailVC
            newVC.title = newFratName
            newVC.selectedFraternity = Campus.shared.fraternitiesByName[newFratName]
            return newVC
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let selectedFrat = (viewController as? DetailViewController)?.selectedFraternity?.name,
            let newFratName = getFrat(after: selectedFrat) {
            let newVC = UIStoryboard.main.detailVC
            newVC.title = newFratName
            newVC.selectedFraternity = Campus.shared.fraternitiesByName[newFratName]
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
        let button = UIBarButtonItem(image: frat.isFavorite ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")  ,
                                     style: .plain,
                                     target: self,
                                     action: #selector(MasterViewController.toggleFavorite(sender:)))
        button.title = frat.name
        return button
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





