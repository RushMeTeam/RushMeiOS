//
//  DrawerMenuViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit

fileprivate let fraternitiesSegueIdentifier = "Fraternities"
fileprivate let settingsSegueIdentifier = "Settings"
fileprivate let calendarSegueIdentifier = "Calendar"
fileprivate let mapSegueIdentifier = "Maps"
fileprivate let feedSegueIdentifier = "Feed"

protocol ScrollViewDelegateForwarder {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  func scrollViewDidScroll(_ scrollView : UIScrollView) 
}

class DrawerMenuViewController : UIViewController, UIScrollViewDelegate {
  var pageDelegate : ScrollViewDelegateForwarder? 
  
  @IBOutlet weak var rushMeLogo: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!
  let buttonIcons = [UIImage(named: "FraternitiesIcon"), 
                     UIImage(named: "EventsIcon"),
                     UIImage(named: "MapsIcon"),
                     UIImage(named: "SettingsIcon")]
  lazy var buttons = [UIButton?](repeating: nil, count: buttonIcons.count)
  lazy var canvasViews : [UIView?] = [UIView?](repeating: nil, count: buttonIcons.count)
  private(set) var currentPage : Int = 0
  func set(newCurrentPage : Int) {
    if newCurrentPage >= 0, newCurrentPage < buttons.count {
      currentPage = newCurrentPage
      scrollView.setContentOffset(CGPoint.init(x: 0, y: CGFloat(newCurrentPage)*scrollView.frame.height), animated: true)
    }
  }
  override func viewDidLoad() {
    scrollView.bounces = false
    view.addGestureRecognizer(scrollView.panGestureRecognizer)
  }
  
  @objc func buttonHit(sender : UIButton) {
//    print("nice")
//    for button in buttons {
//      if sender == button {
//        print("Foundem!") 
//      }
//    }
  }
  @objc func scrollButtons(sender : UIGestureRecognizer) {
    let increment = (sender.location(in: view).y > scrollView.frame.midY) ? 1 : -1
    self.set(newCurrentPage: currentPage + increment)
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(scrollButtons(sender:))))
  }
  
  func adjustScrollView() {
    for bNum in 0..<buttonIcons.count {
      if canvasViews[bNum] == nil {
        let newButton = UIButton()
        buttons[bNum] = newButton
        newButton.addTarget(self, action: #selector(buttonHit(sender:)), for: .touchUpInside)

        newButton.setImage(buttonIcons[bNum], for: .normal)  
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
    }
    scrollView.contentSize = CGSize.init(width: scrollView.bounds.width/2, height: CGFloat(buttonIcons.count)*scrollView.frame.height)
    
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pageDelegate?.scrollViewDidScroll(scrollView)
  }
  
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
    pageDelegate?.scrollViewDidEndDecelerating(scrollView)
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let pageWidth = scrollView.frame.height
    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
    currentPage = Int(page)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadViewIfNeeded()
    adjustScrollView()
    scrollView.contentOffset = CGPoint.init(x: 0, y: scrollView.frame.height * CGFloat(currentPage))
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil) { (_) in
      self.canvasViews = [UIView?](repeating: nil, count: self.buttonIcons.count)
      self.adjustScrollView()
      self.scrollView.contentOffset = CGPoint.init(x: 0, y: self.scrollView.frame.height * CGFloat(self.currentPage))
      UIView.animate(withDuration: RMAnimation.ColoringTime, animations: { 
        self.rushMeLogo.alpha = (size.height < size.width) ? 0 : 1
      }, completion: { (_) in
        self.rushMeLogo.isHidden = size.height < size.width
      })
      
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
}


//class AnywhereView : UIView {
//  var desiredView : UIView?
//  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    print("nice touch")
//    if let convertedPoint = desiredView?.convert(point, from: self)
//      ,desiredView!.bounds.contains(convertedPoint)  {
//      
//      print("very nice touch", point, convertedPoint)
//      return self.desiredView!.hitTest(convertedPoint, with: event)
//    }
//    return super.hitTest(point, with: event)
//  }
//}




