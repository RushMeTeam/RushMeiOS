//
//  DrawerMenuViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit

class ScrollButtonViewController : UIViewController, UIScrollViewDelegate {
  
  lazy var setupScrollView: Void = {
    self.scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: view.bounds.height/2-view.bounds.width/2, width: view.bounds.width, height: view.bounds.width))
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
      scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
      scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor)
      ])
    scrollView.accessibilityIdentifier = "drawerMenuScrollView"
    scrollView.clipsToBounds = false
    scrollView.isPagingEnabled = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bounces = false
    view.addGestureRecognizer(scrollView.panGestureRecognizer)
    scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollButtons(sender:))))

  }()
  private(set) var scrollView : UIScrollView!
  var buttonNames : [String] {
    get {
     return [] 
    }
  }
  var buttonIcons : [UIImage?] {
    get {
     return [] 
    }
  }
  lazy var buttons = [UIButton?](repeating: nil, count: buttonIcons.count)
  lazy var canvasViews : [UIView?] = [UIView?](repeating: nil, count: buttonIcons.count)
 
  var calculatedCurrentPage : Int {
    get {
      return Int(floor(((scrollView.contentOffset.y)/(scrollView.bounds.height))))
    }
  }
  private(set) var currentPage : Int = 1
  func set(newCurrentPage : Int) {
    if newCurrentPage >= 0, newCurrentPage < buttons.count {
      currentPage = newCurrentPage
      scrollView.setContentOffset(CGPoint.init(x: 0, y: CGFloat(newCurrentPage)*scrollView.frame.height), animated: true)
    }
  }
  @objc func scrollButtons(sender : UITapGestureRecognizer) {
    for buttonView in canvasViews where buttonView != nil { 
      if buttonView!.frame.contains(sender.location(in: scrollView)) {
        scrollView.scrollRectToVisible(buttonView!.frame, animated: true)
        return
      }
    }
    guard view.bounds.contains(sender.location(in: view)) else {
      return
    }
    let increment = (sender.location(in: view).y > scrollView.frame.midY) ? 1 : -1
    
    set(newCurrentPage: calculatedCurrentPage + increment)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func layoutScrollView() {
    for bNum in 0..<buttonIcons.count {
      if canvasViews[bNum] == nil {
        let newButton = UIButton()
        buttons[bNum] = newButton
        newButton.accessibilityIdentifier = buttonNames[bNum]        
        newButton.setImage(buttonIcons[bNum], for: .normal)  
        newButton.tintColor = .white
        var newFrame = scrollView.frame
        newFrame.size.height = scrollView.bounds.height
        newFrame.size.width = scrollView.bounds.width
        newFrame.origin.x = 0
        newFrame.origin.y = newFrame.size.height*CGFloat(bNum)
        let canvasView = UIView(frame: newFrame)
        scrollView.addSubview(canvasView)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        canvasView.addSubview(newButton)
        NSLayoutConstraint.activate([newButton.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
                                     newButton.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
                                     newButton.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
                                     newButton.topAnchor.constraint(equalTo: canvasView.topAnchor)])
        canvasViews[bNum] = canvasView
      }
      else {
        self.canvasViews[bNum]?.layoutSubviews()
      }
    }
    scrollView.contentSize = CGSize.init(width: scrollView.bounds.width/2, height: CGFloat(buttonIcons.count)*scrollView.bounds.height)
    scrollView.contentOffset = CGPoint.init(x: 0, y: scrollView.bounds.height * CGFloat(currentPage))
  }
  
  override func viewDidLayoutSubviews() {
    _ = setupScrollView
    layoutScrollView()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { (_) in
      for canvasView in self.canvasViews {
       canvasView?.removeFromSuperview() 
      }
      self.canvasViews = [UIView?](repeating: nil, count: self.buttonIcons.count)
      self.layoutScrollView()
      
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
}






