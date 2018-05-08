//
//  ScrollPageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/18/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import DeviceKit



protocol ScrollableItem {
  func updateData() 
}

class ScrollPageViewController: UIViewController,
                                UIScrollViewDelegate,
                                UISplitViewControllerDelegate,
                                ScrollViewDelegateForwarder,
                                SWRevealViewControllerDelegate{
  @IBOutlet var viewControllerScrollView: UIScrollView!
  @IBOutlet var pageControl: UIPageControl!
  var numberOfPages : Int {
    get {
      return orderedViewControllers.count 
    }
  }
  var currentCalculatedPage : Int {
    get {
      let pageWidth = viewControllerScrollView.frame.height
      return Int(floor((viewControllerScrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1)
    
    }
  }
  lazy var pages : [UIView?] = [UIView?].init(repeating: nil, count: self.orderedViewControllers.count)
  
  lazy var scrollIndicator    : CAShapeLayer = CAShapeLayer()
  var currentPage : Int = 1 {
    didSet {
      if let currentVC = currentViewController as? ScrollableItem {
        currentVC.updateData()
      }
    }
  }
  var currentViewController : UIViewController? {
    get {
      return (currentPage >= 0 && currentPage < orderedViewControllers.count) ? orderedViewControllers[currentPage] : nil
    }
  }
  
  static var startingPageIndex : Int = 1
  lazy var orderedViewControllers: [UIViewController] = 
    [ScrollPageViewController.getViewController(forIdentifier: "mapVC"),
     ScrollPageViewController.getViewController(forIdentifier: "splitVC"),
     ScrollPageViewController.getViewController(forIdentifier: "calendarVC"),
     ScrollPageViewController.getViewController(forIdentifier: "settingsViewController")]
  
  static func getViewController(forIdentifier identifier : String) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) 
  }
  var transitioning = false
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = setupInitialPages
  }
  
  func open(fraternityNamed fratName : String) {
   for childVC in orderedViewControllers[1].childViewControllers {
      if let _ = childVC as? UINavigationController,
        let tableVC = childVC.childViewControllers.first as? MasterViewController,
        let row =  tableVC.dataKeys.index(of: fratName) {
        _ = escapeDetailIfNecessary()
        tableVC.viewingFavorites = false
        tableVC.performSegue(withIdentifier: "showDetail", sender: IndexPath.init(row: row, section: 0))
        goToPage(page: 1, animated: true)
        return
      }
    }
  }
  func escapeDetailIfNecessary() -> Bool {
    return ((currentViewController as? UISplitViewController)?.viewControllers.first as? UINavigationController)?.popToRootViewController(animated: true) != nil 
  }
  
  @IBAction func presentDrawer(_ sender: UIBarButtonItem? = nil) {
    if !escapeDetailIfNecessary() {
      self.revealViewController().revealToggle(animated: true)
    }
  }
  @objc func presentAbout() {
    //print("opened aboutVC")
    present(ScrollPageViewController.getViewController(forIdentifier: "aboutVC"), animated: true, completion: nil) 
  }
  private(set) lazy var setupInitialPages : Void = {
    adjustScrollView()
    loadAllPages()
    transitioning = true
    goToPage(page: ScrollPageViewController.startingPageIndex, animated: false)
    transitioning = false
  }()
  private(set) lazy var progressBar : UIProgressView = {
    let bar = UIProgressView()
    bar.tintColor = RMColor.AppColor
    bar.trackTintColor = .clear
    bar.progress = 0
    return bar
  }()
  private(set) lazy var titleImageView : UIImageView = {
    let imageView = UIImageView.init(image: RMImage.LogoImage)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = RMColor.AppColor
    imageView.backgroundColor = .clear
    imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 44)
    return imageView
  }()
  private(set) lazy var setupNavigationBar : Void = {
    guard let _ = navigationController else {
     return 
    }
    navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController!.navigationBar.shadowImage = UIImage()
    navigationController!.navigationBar.tintColor = RMColor.AppColor
    navigationController!.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
    navigationController!.navigationBar.isTranslucent = false
   // navigationController?.navigationBar.backgroundColor = .white//UIColor.white.withAlphaComponent(0.5)
    navigationController!.navigationBar.barTintColor = .white//.white //RMColor.AppColor
    navigationController!.navigationBar.layer.backgroundColor = UIColor.white.cgColor
    navigationController!.navigationBar.layer.shadowColor = UIColor.white.cgColor
    // Set up Title View
    navigationItem.titleView = UIView()
        // TODO: Allow navigation to "About" 
    titleImageView.translatesAutoresizingMaskIntoConstraints = false
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    progressBar.progress = 0
    navigationItem.titleView!.addSubview(titleImageView)
    navigationItem.titleView!.addSubview(progressBar)
    NSLayoutConstraint.activate([titleImageView.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor),
                                 titleImageView.rightAnchor.constraint(equalTo: navigationController!.navigationBar.rightAnchor),
                                 titleImageView.heightAnchor.constraint(equalToConstant: min(32, navigationController!.navigationBar.frame.height)),
                                 titleImageView.centerYAnchor.constraint(equalTo: navigationItem.titleView!.centerYAnchor),
                                 progressBar.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor),
                                 progressBar.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor),
                                 progressBar.rightAnchor.constraint(equalTo: navigationController!.navigationBar.rightAnchor)])
  }()
  
  fileprivate func adjustScrollView() {
    viewControllerScrollView.contentSize = CGSize.init(width: viewControllerScrollView.frame.width, 
                                         height: viewControllerScrollView.frame.height * CGFloat(numberOfPages) - topLayoutGuide.length)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { (_) in
      self.adjustScrollView()
      self.pages = [UIView?](repeatElement(nil, count: self.numberOfPages))
      self.goToPage(page: self.currentPage, animated: false)
      self.transitioning = false
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _ = setupNavigationBar
    viewControllerScrollView.delegate = self
    viewControllerScrollView.isScrollEnabled = false
    viewControllerScrollView.backgroundColor = .white
    
    view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    
    view.backgroundColor = .white
    // Do any additional setup after loading the view.
    pages = [UIView?](repeating: nil, count : numberOfPages)
    pageControl.numberOfPages = numberOfPages
    pageControl.currentPage = ScrollPageViewController.startingPageIndex
    Campus.shared.percentageCompletionObservable.addObserver(forOwner: self, handler: handlePercentageCompletion(oldValue:newValue:))
  }
  private func handlePercentageCompletion(oldValue : Float?, newValue : Float) {
    DispatchQueue.main.async {
      self.progressBar.setProgress(max(newValue, 0.05), animated: true) 
      if newValue == 1 {
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: { 
          self.progressBar.alpha = 0
        }, completion: { (_) in
          self.progressBar.progress = 0
          self.progressBar.alpha = 1
          (self.orderedViewControllers[2] as? CalendarViewController)?.updateData()
        })
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  fileprivate func loadPage(_ page : Int) {
    guard page < numberOfPages && page >= 0 else {
      //print("Attemped to load illegal page number", page)
      return 
    }
    if pages[page] == nil {
      let newViewController = self.orderedViewControllers[page]
      var newFrame = self.viewControllerScrollView.frame
      newFrame.origin.x = 0
      newFrame.origin.y = newFrame.height * CGFloat(page)
      let canvasView = UIView.init(frame: newFrame)
      newViewController.willMove(toParentViewController: self)
      addChildViewController(newViewController)
      newViewController.didMove(toParentViewController: self)
      viewControllerScrollView.addSubview(canvasView)
      newViewController.view!.translatesAutoresizingMaskIntoConstraints = false
      canvasView.addSubview(newViewController.view!)
      NSLayoutConstraint.activate([newViewController.view!.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                   newViewController.view!.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                   newViewController.view!.topAnchor.constraint(equalTo: canvasView.topAnchor),
                                   newViewController.view!.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)])
      self.pages[page] = canvasView
    }
  }
  fileprivate func loadCurrentPages(page: Int) {
    guard (page > 0 && page + 1 < numberOfPages) || transitioning else {
      //print("Attemped to load multiple illegal pages surrounding page number", page)
      return
    }
    pages = [UIView?](repeating: nil, count: numberOfPages)
    loadPage(Int(page) - 1)
    loadPage(Int(page))
    loadPage(Int(page) + 1)
    
  }
  func loadAllPages() {
    for pageNum in 0..<orderedViewControllers.count {
     loadPage(pageNum) 
    }
  }
  
  // Originally fileprivate
  func goToPage(page: Int, animated: Bool) {
    guard page >= 0 && page < numberOfPages else {
      //print("Attemped to goTo illegal page number", page)
      return 
    }
    loadCurrentPages(page: page)
    var bounds = viewControllerScrollView.bounds
    bounds.origin.x = 0
    bounds.origin.y = bounds.height * CGFloat(page)
    transitioning = true
    viewControllerScrollView.scrollRectToVisible(bounds, animated: animated)
    (revealViewController()?.rearViewController as? DrawerMenuViewController)?.set(newCurrentPage: page)
    transitioning = false
    currentPage = page
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
    
  }
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { currentPage = currentCalculatedPage }
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { currentPage = currentCalculatedPage }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView != viewControllerScrollView {
      viewControllerScrollView.setContentOffset(scrollView.contentOffset.applying(CGAffineTransform.init(scaleX: 1, y: self.viewControllerScrollView.frame.height/scrollView.frame.height)) , animated: false)
    }
  }

  
  @IBAction func goToPage(_ sender: UIPageControl) {
    goToPage(page: sender.currentPage, animated: true) 
  }
  // MARK: SWRevealViewControllerDelegate
  func revealControllerPanGestureShouldBegin(_ revealController: SWRevealViewController!) -> Bool {
    return true
  }
  func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
    viewControllerScrollView.isUserInteractionEnabled = position != .right
    // Escape from Detail
    (currentViewController as? ScrollableItem)?.updateData()
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
