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
UIScrollViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var pageControl: UIPageControl!
  var numberOfPages : Int {
    get {
      return orderedViewControllers.count 
    }
  }
  lazy var pages : [UIView?] = [UIView.init()]
  
  lazy var scrollIndicator    : CAShapeLayer = CAShapeLayer()
  var path : UIBezierPath {
    get {
      return UIBezierPath.init(roundedRect: CGRect.init(x: 0.9*scrollView.contentOffset.x / scrollView.contentSize.width, 
                                                        y: self.view.frame.maxY, 
                                                        width: self.view.frame.width / CGFloat(numberOfPages), 
                                                        height: 10), 
                               cornerRadius: 3)
    }
  }
  var currentPage : Int = 1 {
    willSet {
      let correctedNewValue = min(numberOfPages - 1, max(newValue, 0))
      if correctedNewValue != currentPage {
        pageControl.currentPage = newValue
        // Update information!!!
        if let viewController = self.orderedViewControllers[correctedNewValue].childViewControllers.first, 
          let updatableItem = viewController as? ScrollableItem {
          updatableItem.updateData()
        }
        self.loadCurrentPages(page: self.pageControl.currentPage)
      }
    }
  }
  
  var startingPageIndex : Int = 1 {
    didSet {
      loadView()
      pageControl.currentPage = startingPageIndex
      transitioning = true
      goToPage(page: startingPageIndex, animated: true)
      transitioning = false
    }
  }
  var orderedViewControllers: [UIViewController] = 
    [ScrollPageViewController.getViewController(forIdentifier: "mapVC"), 
     ScrollPageViewController.getViewController(forIdentifier: "splitVC"), 
     ScrollPageViewController.getViewController(forIdentifier: "calendarVC")]
  var viewControllerIdentifiers = ["mapVC", "splitVC", "calendarVC"]
  
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
  
  @IBAction func presentSettings(_ sender: UIBarButtonItem) {
    present(ScrollPageViewController.getViewController(forIdentifier: "settingsVC"), animated: true, completion: nil)
  }
  @objc func presentAbout() {
    //print("opened aboutVC")
    present(ScrollPageViewController.getViewController(forIdentifier: "aboutVC"), animated: true, completion: nil) 
  }
  
  
  lazy var setupInitialPages : Void = {
    adjustScrollView()
    loadPage(1)
    loadPage(2)
    loadPage(0)
    transitioning = true
    goToPage(page: startingPageIndex, animated: false)
    transitioning = false
  }()
  
  fileprivate func adjustScrollView() {
    scrollView.contentSize = CGSize.init(width: scrollView.frame.width * CGFloat(numberOfPages), 
                                         height: scrollView.frame.height - topLayoutGuide.length)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil) { (_) in
      self.adjustScrollView()
      self.pages = [UIView?](repeatElement(nil, count: self.numberOfPages))
      self.goToPage(page: self.pageControl.currentPage, animated: false)
      self.transitioning = false
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    navigationController?.navigationBar.alpha = 0.5
    navigationController?.navigationBar.tintColor = RMColor.AppColor
    navigationController?.navigationBar.barTintColor = UIColor.white//RMColor.AppColor
    navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.AppColor]
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
    pageControl.currentPage = startingPageIndex
    
    self.scrollView.layer.addSublayer(scrollIndicator)
    goToPage(page: startingPageIndex, animated: false)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  fileprivate func loadPage(_ page : Int) {
    guard page < numberOfPages && page >= 0 else {
      print("Attemped to load illegal page number", page)
      return 
    }
    if pages[page] == nil {
      let newViewController = orderedViewControllers[page]
      //newView.backgroundColor = page == 0 ? .blue : .green
      var newFrame = scrollView.frame
      newFrame.origin.x = newFrame.width * CGFloat(page)
      newFrame.origin.y = -self.topLayoutGuide.length
      newFrame.size.height += self.topLayoutGuide.length
      let canvasView = UIView.init(frame: newFrame)
      newViewController.willMove(toParentViewController: self)
      self.addChildViewController(newViewController)
      newViewController.didMove(toParentViewController: self)
      scrollView.addSubview(canvasView)
      newViewController.view!.translatesAutoresizingMaskIntoConstraints = false
      canvasView.addSubview(newViewController.view!)
      NSLayoutConstraint.activate([newViewController.view!.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                   newViewController.view!.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                   newViewController.view!.topAnchor.constraint(equalTo: canvasView.topAnchor),
                                   newViewController.view!.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
        ])
      pages[page] = canvasView
    }
  }
  fileprivate func loadCurrentPages(page: Int) {
    guard (page > 0 && page + 1 < numberOfPages) || transitioning else {
      print("Attemped to load multiple illegal pages surrounding page number", page)
      return
    }
    pages = [UIView?](repeating: nil, count: numberOfPages)
    loadPage(Int(page) - 1)
    loadPage(Int(page))
    loadPage(Int(page) + 1)
  }
  
  // Originally fileprivate
  func goToPage(page: Int, animated: Bool) {
    guard page >= 0 && page < numberOfPages else {
      print("Attemped to goTo illegal page number", page)
      return 
    }
    loadCurrentPages(page: page)
    var bounds = scrollView.bounds
    bounds.origin.x = bounds.width * CGFloat(page)
    bounds.origin.y = 0
    scrollView.scrollRectToVisible(bounds, animated: animated)
    currentPage = page
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.width
    let page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //    let currentPageIndex = pageControl.currentPage
    //    let leftPageIndex = pageControl.currentPage - 1
    //    let rightpageIndex = pageControl.currentPage + 1
    //    if let currentPage = currentPageIndex >= 0 && currentPageIndex <= numberOfPages ? orderedViewControllers[currentPageIndex].view : nil {
    //      print(scrollView.contentOffset.x, currentPage.center.x)
    //      currentPage.alpha = 3*abs(currentPage.center.x - scrollView.contentOffset.x)/self.view.frame.width
    //    }
  }
  
  
  @IBAction func goToPage(_ sender: UIPageControl) {
    goToPage(page: sender.currentPage, animated: true) 
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
