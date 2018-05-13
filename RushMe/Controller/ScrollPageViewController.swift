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

protocol SegueDelegate {
  
}

class ScrollPageViewController: UIViewController,
                                UIScrollViewDelegate,
                                UISplitViewControllerDelegate,
                                ScrollViewDelegateForwarder,
                                SWRevealViewControllerDelegate,
                                UIPageViewControllerDelegate{
  private(set) lazy var setupScrollView : UIScrollView = {
    scrollView = UIScrollView(frame: view.bounds)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.leftAnchor.constraint(equalTo: view.leftAnchor)
      , scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
      , scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
      , scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
      ])
    scrollView.isScrollEnabled = false
    scrollView.isPagingEnabled = true
    scrollView.delegate = nil
    return scrollView
  }()
  private(set) var scrollView : UIScrollView!
  @IBOutlet var pageControl: UIPageControl!
  var numberOfPages : Int {
    get {
      return orderedViewControllers.count 
    }
  }
  var currentCalculatedPage : Int {
    get {
      return Int(floor((scrollView.contentOffset.y - pageHeight/2)/pageHeight) + 1)
    
    }
  }
  lazy var pages : [UIView?] = [UIView?].init(repeating: nil, count: self.orderedViewControllers.count)
  
  lazy var scrollIndicator : CAShapeLayer = CAShapeLayer()
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
  private(set) lazy var orderedViewControllers: [UIViewController] = 
    [viewController(forIdentifier: "mapVC"),
     viewController(forIdentifier: "masterVC"),
     viewController(forIdentifier: "calendarVC"),
     viewController(forIdentifier: "settingsViewController")]
  
  func viewController(forIdentifier identifier : String) -> UIViewController {
    let newVCInstance = UIStoryboard.main.instantiateViewController(withIdentifier: identifier)
   
    return newVCInstance
  }
  
  
  var transitioning = false
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = setupScrollView
    _ = setupInitialPages
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      revealViewController().panGestureRecognizer().isEnabled = false
    }
    (segue.destination as? UIPageViewController)?.delegate = self
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed, let fratName = (pageViewController.viewControllers?.first as? DetailViewController)?.selectedFraternity?.name {
      SQLHandler.inform(action: .FraternitySelected, options: fratName) 
      pageViewController.title = fratName.greekLetters
    }
  }
  
  @IBAction func presentDrawer(_ sender: UIBarButtonItem? = nil) {
    self.revealViewController().revealToggle(animated: true)
  }
  @objc func presentAbout() {
    present(viewController(forIdentifier: "aboutVC"), animated: true, completion: nil) 
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
  private(set) lazy var titleImageView : UIView = {
    let imageView = UIImageView.init(image: RMImage.LogoImage)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = RMColor.AppColor
    imageView.backgroundColor = .clear
    let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 32))
    imageView.frame = titleView.bounds
    titleView.addSubview(imageView)
    return titleView
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
    navigationController!.navigationBar.barTintColor = .white
    navigationController!.navigationBar.layer.backgroundColor = UIColor.white.cgColor//RMColor.AppColor.cgColor//UIColor.clear.cgColor//UIColor.white.cgColor
    navigationController!.navigationBar.layer.shadowColor = UIColor.white.cgColor
    // Set up Title View
//    navigationItem.setRightBarButton(UIBarButtonItem.init(title: "          .", style: .plain, target: nil, action: nil), animated: false)
    //navigationController!.navigationBar.setRightBarButton(UIBarButtonItem.init(customView: UIView()), animated: false)
    navigationItem.titleView = titleImageView
    
//    navigationItem.titleView?.addSubview()
    //let titleImageView = UIImageView(image: #imageLiteral(resourceName: "RushMeLogoInverted"))
    //titleImageView.frame = CGRect.init(x: navigationItem.titleView!.frame.midX - navigationItem.titleView!.frame.minX, y: 0, width: navigationItem.titleView!.frame.width, height: 32)
    //navigationItem.titleView!.addSubview(titleImageView)
    // TODO: Allow navigation to "About" 
//    titleImageView.translatesAutoresizingMaskIntoConstraints = false
//    progressBar.translatesAutoresizingMaskIntoConstraints = false
//    progressBar.progress = 0
//    navigationItem.titleView!.addSubview(titleImageView)
//    navigationItem.titleView!.addSubview(progressBar)
//    NSLayoutConstraint.activate([titleImageView.leftAnchor.constraint(equalTo: navigationItem.titleView!.leftAnchor),
//                                 titleImageView.rightAnchor.constraint(equalTo: navigationItem.titleView!.rightAnchor),
//                                 titleImageView.heightAnchor.constraint(equalTo: navigationItem.titleView!.heightAnchor),
//                                 titleImageView.centerYAnchor.constraint(equalTo: navigationItem.titleView!.centerYAnchor),
//                                 progressBar.bottomAnchor.constraint(equalTo: navigationItem.titleView!.bottomAnchor),
//                                 progressBar.leftAnchor.constraint(equalTo: navigationItem.titleView!.leftAnchor),
//                                 progressBar.rightAnchor.constraint(equalTo: navigationItem.titleView!.rightAnchor)
//      ])
  }()
  
  fileprivate func adjustScrollView() {
    scrollView.contentSize = CGSize.init(width: scrollView.frame.width, 
                                         height: scrollView.frame.height * CGFloat(numberOfPages) - topLayoutGuide.length)
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
    view.backgroundColor = .white
    // Do any additional setup after loading the view.
    pages = [UIView?](repeating: nil, count : numberOfPages)
    pageControl.numberOfPages = numberOfPages
    pageControl.currentPage = ScrollPageViewController.startingPageIndex
    Campus.shared.percentageCompletionObservable.addObserver(forOwner: self, handler: handlePercentageCompletion(oldValue:newValue:))
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    revealViewController().panGestureRecognizer().isEnabled = true
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
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    revealViewController().panGestureRecognizer().isEnabled = false

  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  var pageHeight : CGFloat {
    get {
      return scrollView.bounds.height //- topLayoutGuide.length - bottomLayoutGuide.length
    }
  }
  
  
  fileprivate func loadPage(_ page : Int) {
    guard page < numberOfPages && page >= 0 else {
      //print("Attemped to load illegal page number", page)
      return 
    }
    if pages[page] == nil {
      let newViewController = self.orderedViewControllers[page]
      let canvasView = UIView(frame: CGRect(x: 0, y: (pageHeight)*CGFloat(page), width: view.bounds.width, height: pageHeight))
      canvasView.clipsToBounds = true
      canvasView.layer.masksToBounds = true
      newViewController.willMove(toParentViewController: self)
      addChildViewController(newViewController)
      newViewController.didMove(toParentViewController: self)
      scrollView.addSubview(canvasView)
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
    var bounds = scrollView.bounds
    bounds.origin.x = 0
    bounds.origin.y = pageHeight * CGFloat(page) - topLayoutGuide.length - bottomLayoutGuide.length
    transitioning = true
    scrollView.scrollRectToVisible(bounds, animated: animated)
    (revealViewController()?.rearViewController as? DrawerMenuViewController)?.set(newCurrentPage: page)
    transitioning = false
    currentPage = page
  }
  // MARK: UIScrollViewDelegate
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {}
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.scrollView.contentOffset = scrollView.contentOffset.applying(
      CGAffineTransform(scaleX: 1, y: self.scrollView.bounds.height/scrollView.bounds.height)
                                                                      )
  }

  @IBAction func goToPage(_ sender: UIPageControl) {
    goToPage(page: sender.currentPage, animated: true) 
  }
  // MARK: SWRevealViewControllerDelegate
  func revealControllerPanGestureShouldBegin(_ revealController: SWRevealViewController!) -> Bool {
    return true
  }
  func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
    scrollView?.isUserInteractionEnabled = !(position == .right || position == .rightMost)
    scrollView?.isScrollEnabled = position == .right
    // Escape from Detail'
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

class SegueDesignator : UIViewController {
  var delegate : UIViewController!
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    delegate!.prepare(for: segue, sender: sender)
  }
}


