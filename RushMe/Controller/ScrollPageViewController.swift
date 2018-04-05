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
    return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) 
  }
  var transitioning = false
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = setupInitialPages
  }
  override func awakeFromNib() {
    // TODO: Finish Scroll Indicator!
  
  }
  
  func open(fraternityNamed fratName : String) {
   
   for childVC in orderedViewControllers[1].childViewControllers {
      if let _ = childVC as? UINavigationController,
        let tableVC = childVC.childViewControllers.first as? MasterViewController,
        let row =  tableVC.dataKeys.index(of: fratName) {
        tableVC.viewingFavorites = false
        tableVC.tableView.selectRow(at: IndexPath.init(row: row, section: 0), animated: true, scrollPosition: .top)
        tableVC.performSegue(withIdentifier: "showDetail", sender: self)
        goToPage(page: 1, animated: true)
      }
    }
  }
  
  @IBAction func presentDrawer(_ sender: UIBarButtonItem? = nil) {
    //present(ScrollPageViewController.getViewController(forIdentifier: "settingsVC"), animated: true, completion: nil)
    self.revealViewController().revealToggle(animated: true)
  }
  @objc func presentAbout() {
    //print("opened aboutVC")
    present(ScrollPageViewController.getViewController(forIdentifier: "aboutVC"), animated: true, completion: nil) 
  }
  
  
  lazy var setupInitialPages : Void = {
    adjustScrollView()
    loadAllPages()
    transitioning = true
    goToPage(page: ScrollPageViewController.startingPageIndex, animated: false)
    transitioning = false
  }()
  
  fileprivate func adjustScrollView() {
    viewControllerScrollView.contentSize = CGSize.init(width: viewControllerScrollView.frame.width, 
                                         height: viewControllerScrollView.frame.height * CGFloat(numberOfPages) - topLayoutGuide.length)
    
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
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
    viewControllerScrollView.delegate = self
    viewControllerScrollView.isScrollEnabled = false
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    navigationController?.navigationBar.tintColor = RMColor.AppColor
    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
    view.backgroundColor = .white
    viewControllerScrollView.backgroundColor = .white
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.backgroundColor = .white//UIColor.white.withAlphaComponent(0.5)
    navigationController?.navigationBar.barTintColor = .white//.white //RMColor.AppColor
    navigationController?.navigationBar.layer.backgroundColor = UIColor.white.cgColor
    navigationController?.navigationBar.layer.shadowColor = UIColor.white.cgColor
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
    imageView.center = wrapperView.center
    self.navigationItem.titleView = wrapperView
    // TODO: Allow navigation to "About" 
    //    self.navigationItem.titleView!.isUserInteractionEnabled = true
    //    let aboutTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(presentAbout))
    //    self.navigationItem.titleView!.addGestureRecognizer(aboutTapGestureRecognizer)
    // Do any additional setup after loading the view.
    pages = [UIView?](repeating: nil, count : numberOfPages)
    pageControl.numberOfPages = numberOfPages
    pageControl.currentPage = ScrollPageViewController.startingPageIndex
    goToPage(page: ScrollPageViewController.startingPageIndex, animated: false)
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
      DispatchQueue.global(qos: .userInitiated).async {
        let newViewController = self.orderedViewControllers[page]
        DispatchQueue.main.async {
        var newFrame = self.viewControllerScrollView.frame
        newFrame.origin.x = 0
        newFrame.origin.y = newFrame.height * CGFloat(page)
        let canvasView = UIView.init(frame: newFrame)
          newViewController.willMove(toParentViewController: self)
          self.addChildViewController(newViewController)
          newViewController.didMove(toParentViewController: self)
          self.viewControllerScrollView.addSubview(canvasView)
          newViewController.view!.translatesAutoresizingMaskIntoConstraints = false
          canvasView.addSubview(newViewController.view!)
          NSLayoutConstraint.activate([newViewController.view!.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                       newViewController.view!.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                       newViewController.view!.topAnchor.constraint(equalTo: canvasView.topAnchor),
                                       newViewController.view!.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)])
          self.pages[page] = canvasView
        }
      }
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
     self.loadPage(pageNum) 
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
    transitioning = false
    currentPage = page
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
  }
//  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//    
//  }
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
  }
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView != viewControllerScrollView {
      viewControllerScrollView.setContentOffset(scrollView.contentOffset.applying(CGAffineTransform.init(scaleX: 1, y: self.viewControllerScrollView.frame.height/scrollView.frame.height)) , animated: false)
    }
    //    let currentPageIndex = pageControl.currentPage
    //    let leftPageIndex = pageControl.currentPage - 1
    //    let rightpageIndex = pageControl.currentPage + 1
    //    if let currentPage = currentPageIndex >= 0 && currentPageIndex <= numberOfPages ? orderedViewControllers[currentPageIndex].view : nil {
    //      print(scrollView.contentOffset.x, currentPage.center.x)
    //      currentPage.alpha = 3*abs(currentPage.center.x - scrollView.contentOffset.x)/self.view.frame.width
    //    }
    //    transform.m34 = -1.0 / 500.0
    //    
    //    let rotation = *0.5*CGFloat.pi
    //    transform = CATransform3DRotate(transform, rotation, 0.0, 1.0, 0.0)
    
    //pageView.layer.anchorPoint = CGPoint(x: (pageView.bounds.midX-pageView.frame.midX/CGFloat(currentPage))/pageView.bounds.width, y:0.5)
    //pageView.layer.setAffineTransform(transform)
    //    pageView.layer.contentsScale = 0.9
    
    
//    let pageView = orderedViewControllers[currentPage].view!
//    let scale = abs(((pageView.bounds.maxX-(scrollView.contentOffset.x)/CGFloat(currentPage)))/pageView.bounds.width)
//    let transform = CGAffineTransform.init(scaleX: scale, y: scale)
//
//    for page in pages {
//      if page != pageView {
//       page?.layer.setAffineTransform(CGAffineTransform.identity)
//      }
//    }
    
    
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
    if position == .left, let cVC = currentViewController as? ScrollableItem {
     cVC.updateData()
    }
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
