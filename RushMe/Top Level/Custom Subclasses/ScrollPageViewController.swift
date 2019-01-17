//
//  ScrollPageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/18/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

protocol ScrollableItem {
  func updateData() 
}

class ScrollPageViewController: UIViewController,
                                UIScrollViewDelegate
                                {
  private(set) lazy var setupScrollView : UIScrollView = {
    scrollView = UIScrollView(frame: view.bounds)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.leftAnchor.constraint(equalTo: view.leftAnchor)
      , scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
      , scrollView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor)
      , scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor)
      ])
    scrollView.isScrollEnabled = false
    scrollView.isPagingEnabled = true
    scrollView.delegate = nil
    return scrollView
  }()
  private(set) var scrollView : UIScrollView!
  var pageControl: UIPageControl = UIPageControl()
  var numberOfPages : Int {
    get {
      return pageViewControllers.count 
    }
  }
  internal var pageViewControllers: [UIViewController]!
  private(set) lazy var pageCanvases : [UIView?] = [UIView?](repeating: nil, count: self.pageViewControllers.count)
  var progress : Float {
    get {
      return progressBar?.progress ?? 0
    }
    set {
      guard let _ = progressBar else {
        print("Tried to set progress on a null bar!")
       return 
      }
      DispatchQueue.main.async {
        if newValue == 1 {
          UIView.animate(withDuration: Frontend.animations.defaultDuration, animations: { 
            self.progressBar.alpha = 0
            self.progressBar.progress = 1
          }, completion: { (_) in
            self.progressBar.progress = 0
            self.progressBar.alpha = 1
          })
        }
        else {
          self.progressBar.setProgress(max(newValue, 0.05), animated: true)  
        }
      }
    }
  }
  var currentPage : Int = 2 {
    didSet {
      (currentViewController as? ScrollableItem)?.updateData()
    }
  }
  var currentViewController : UIViewController! {
    get {
      return (currentPage >= 0 && currentPage < pageViewControllers.count) ? pageViewControllers[currentPage] : nil
    }
  }
  
  static var startingPageIndex : Int = 2
  
  
  var transitioning = false
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = setupScrollView
    _ = setupInitialPages
  }
  

  
  
  
  @objc private func presentAbout() {
    present(UIStoryboard.main.instantiateViewController(withIdentifier: "aboutVC"), animated: true, completion: nil) 
  }
  private lazy var setupInitialPages : Void = {
    adjustScrollView()
    loadAllPages()
    transitioning = true
    goToPage(page: ScrollPageViewController.startingPageIndex, animated: false)
    transitioning = false
  }()
  private(set) var progressBar : UIProgressView!
  private lazy var setupProgressBar : Void = {
    progressBar = UIProgressView()
    progressBar.tintColor = Frontend.colors.AppColor
    progressBar.trackTintColor = .clear
    progressBar.progress = 0
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    navigationController!.navigationBar.addSubview(progressBar)
    NSLayoutConstraint.activate([
      progressBar.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor),
      progressBar.rightAnchor.constraint(equalTo: navigationController!.navigationBar.rightAnchor),
      progressBar.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: 0),
      progressBar.heightAnchor.constraint(equalToConstant: 3)
      ])
  }()
  private(set) lazy var setupNavigationBar : Void = {
    guard let _ = navigationController else {
     return 
    }
    navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController!.navigationBar.shadowImage = UIImage()
    navigationController!.navigationBar.isTranslucent = false
    navigationController!.navigationBar.layer.backgroundColor = UIColor.white.cgColor
    navigationController!.navigationBar.layer.shadowColor = UIColor.white.cgColor
    navigationController!.navigationBar.barTintColor = Frontend.colors.NavigationBarColor
    // Set up Title View
    navigationItem.titleView = titleImageView
  }()
  var titleImage : UIImage {
    get {
      return UIImage()
    }
  }
  internal lazy var titleImageView : UIView = {
    let imageView = UIImageView.init(image: titleImage)
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .clear
    let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 32))
    imageView.frame = titleView.bounds
    titleView.addSubview(imageView)
    return titleView
  }()
  
  @IBAction func unwindToScroll(segue : UIStoryboardSegue) {}

  
  fileprivate func adjustScrollView() {
    scrollView.contentSize = CGSize.init(width: scrollView.frame.width, 
                                         height: scrollView.frame.height * CGFloat(numberOfPages) - topLayoutGuide.length)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { (_) in
      self.adjustScrollView()
      self.pageCanvases = [UIView?](repeatElement(nil, count: self.numberOfPages))
      self.goToPage(page: self.currentPage, animated: false)
      self.transitioning = false
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _ = setupNavigationBar
    _ = setupProgressBar
    // Do any additional setup after loading the view.
    pageControl.numberOfPages = numberOfPages
    pageControl.currentPage = ScrollPageViewController.startingPageIndex
  }

  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.barTintColor = Frontend.colors.NavigationBarColor
    self.navigationController?.navigationBar.tintColor = Frontend.colors.NavigationBarTintColor
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedString.Key.foregroundColor: navigationController!.navigationBar.tintColor]

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
  
  
  fileprivate func loadPage(_ pageIndex : Int) {
    guard pageIndex < numberOfPages && pageIndex >= 0 else {
      return 
    }
    if pageCanvases[pageIndex] == nil {
      let newViewController = self.pageViewControllers[pageIndex]
      let canvasView = UIView(frame: CGRect(x: 0, y: (pageHeight)*CGFloat(pageIndex), width: view.bounds.width, height: pageHeight))
      canvasView.clipsToBounds = true
      newViewController.willMove(toParent: self)
      addChild(newViewController)
      newViewController.didMove(toParent: self)
      scrollView.addSubview(canvasView)
      newViewController.view!.translatesAutoresizingMaskIntoConstraints = false
      canvasView.addSubview(newViewController.view!)
      NSLayoutConstraint.activate([newViewController.view!.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                   newViewController.view!.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                   newViewController.view!.topAnchor.constraint(equalTo: canvasView.topAnchor),
                                   newViewController.view!.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)])
      pageCanvases[pageIndex] = canvasView
    }
  }
  fileprivate func loadPages(aroundPage: Int) {
    guard (aroundPage > 0 && aroundPage + 1 < numberOfPages) || transitioning else {      return
    }
    pageCanvases = [UIView?](repeating: nil, count: numberOfPages)
    loadPage(Int(aroundPage) - 1)
    loadPage(Int(aroundPage))
    loadPage(Int(aroundPage) + 1)
    
  }
  func loadAllPages() {
    for pageNum in 0..<pageViewControllers.count {
     loadPage(pageNum) 
    }
  }
  
  // Originally fileprivate
  func goToPage(page: Int, animated: Bool) {
    
    guard page >= 0 && page < numberOfPages else {
      //print("Attemped to goTo illegal page number", page)
      return 
    }
    loadPages(aroundPage: page)
    var bounds = scrollView.bounds
    bounds.origin.x = 0
    bounds.origin.y = pageHeight * CGFloat(page)
    transitioning = true
    scrollView.scrollRectToVisible(bounds, animated: animated)
    transitioning = false
    currentPage = page
  }
  // MARK: UIScrollViewDelegate
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    currentPage = Int(floor((scrollView.contentOffset.y)/pageHeight))
  }
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {}
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView != self.scrollView else {
     return 
    }
    self.scrollView.contentOffset = scrollView.contentOffset.applying(
      CGAffineTransform(scaleX: 1, y: pageHeight/scrollView.bounds.height)
                                                            )
    let newCalculatedPage = Int(floor((scrollView.contentOffset.y)/pageHeight))
    if newCalculatedPage != currentCalculatedPage {
      UISelectionFeedbackGenerator().selectionChanged()
    }
    currentCalculatedPage = newCalculatedPage
  }
  var currentCalculatedPage : Int = 1
  @IBAction func goToPage(_ sender: UIPageControl) {
    goToPage(page: sender.currentPage, animated: true) 
  }
  
  
}

