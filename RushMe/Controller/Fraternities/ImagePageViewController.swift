//
//  ScrollPageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/18/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import DeviceKit

class ImagePageViewController: UIViewController,
UIScrollViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var pageControl: UIPageControl!
  var numberOfPages : Int {
    get {
      return imageNames.count 
    }
  }
  lazy var pages : [UIView?] = [UIView.init()]
  
  var currentPageIndex : Int = 0 {
    willSet {
      let correctedNewValue = min(numberOfPages - 1, max(newValue, 0))
      if correctedNewValue != currentPageIndex {
        pageControl.currentPage = newValue
        // Update information!!!
        loadCurrentPages(page: self.pageControl.currentPage)
      }
    }
  }
  var currentPageImage : UIImage? {
    get {
     return (pages[currentPageIndex]?.subviews.first as? UIImageView)?.image
    }
  }
  var contentMode : UIViewContentMode = .scaleAspectFill {
    willSet {
      for page in pages {
        if let imageView = page?.subviews.first as? UIImageView {
         imageView.contentMode = contentMode 
        }
      }
    }
  }
  
  var startingPageIndex : Int = 1 {
    didSet {
      loadViewIfNeeded()
      pageControl.currentPage = startingPageIndex
      transitioning = true
      goToPage(page: startingPageIndex, animated: true)
      transitioning = false
    }
  }
  var imageNames: [String] = ["defaultImage.png"] {
    didSet {
      self.pages = [UIView?](repeatElement(nil, count: self.numberOfPages))
      self.pageControl.numberOfPages = numberOfPages
      self.loadCurrentPages(page: 0)
    }
  }
  var transitioning = false
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    _ = setupInitialPages
  }
  
  
  lazy var setupInitialPages : Void = {
    adjustScrollView()
    loadPage(0)
    loadPage(1)
    loadPage(2)
  }()
  
  fileprivate func adjustScrollView() {
    scrollView.contentSize = CGSize.init(width: scrollView.frame.width * CGFloat(numberOfPages), 
                                         height: scrollView.frame.height - topLayoutGuide.length)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil) { (_) in
      self.pages = [UIView?](repeatElement(nil, count: self.numberOfPages))
      self.adjustScrollView()
      self.goToPage(page: self.pageControl.currentPage, animated: false)
      
      self.transitioning = false
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    pageControl.hidesForSinglePage = true
    pages = [UIView?](repeating: nil, count : numberOfPages)
    pageControl.numberOfPages = numberOfPages
    pageControl.currentPage = startingPageIndex
    goToPage(page: startingPageIndex, animated: false)
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
      let newView = UIImageView()
      newView.contentMode = contentMode
      //newView.backgroundColor = page == 0 ? .blue : .green
      var newFrame = scrollView.frame
      newFrame.origin.x = newFrame.width * CGFloat(page)
      newFrame.origin.y = -self.topLayoutGuide.length
      newFrame.size.height += self.topLayoutGuide.length
      let canvasView = UIView.init(frame: newFrame)
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      scrollView.addSubview(canvasView)
      newView.translatesAutoresizingMaskIntoConstraints = false
      canvasView.addSubview(newView)
      NSLayoutConstraint.activate([newView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                   newView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                   newView.topAnchor.constraint(equalTo: canvasView.topAnchor),
                                   newView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
        ])
      pages[page] = canvasView
      newView.setImageByURL(fromSource: imageNames[page])
    }
  }
  fileprivate func loadCurrentPages(page: Int) {
    guard (page > 0 && page + 1 < numberOfPages) || transitioning else {
      //print("Attemped to load multiple illegal pages surrounding page number", page)
      return
    }
    loadPage(Int(page) - 1)
    loadPage(Int(page))
    loadPage(Int(page) + 1)
  }
  
  // Originally fileprivate
  func goToPage(page: Int, animated: Bool) {
    guard page >= 0 && page < numberOfPages else {
      //print("Attemped to goTo illegal page number", page)
      return 
    }
    loadCurrentPages(page: page)
    var bounds = scrollView.bounds
    bounds.origin.x = bounds.width * CGFloat(page)
    bounds.origin.y = 0
    scrollView.scrollRectToVisible(bounds, animated: animated)
    currentPageIndex = page
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.width
    let page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
    currentPageIndex = Int(page)
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

