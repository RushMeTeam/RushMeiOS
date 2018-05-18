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
 // var pageDelegate : ScrollViewDelegateForwarder? 
  
  @IBOutlet weak var rushMeLogo: UIImageView!
  static var scrollViewDelegate : UIScrollViewDelegate!
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
    scrollView.clipsToBounds = false
    scrollView.isPagingEnabled = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bounces = false
    scrollView.delegate = DrawerMenuViewController.scrollViewDelegate
    view.addGestureRecognizer(scrollView.panGestureRecognizer)
  }()
  var scrollView : UIScrollView!

  let buttonIcons = [UIImage(named: "MapsIcon"),
                     UIImage(named: "FraternitiesIcon"), 
                     UIImage(named: "EventsIcon"),
                     UIImage(named: "SettingsIcon")]
  lazy var buttons = [UIButton?](repeating: nil, count: buttonIcons.count)
  lazy var canvasViews : [UIView?] = [UIView?](repeating: nil, count: buttonIcons.count)
 
      
    
  func calculateCurrentPage(forOffset offset : CGPoint) -> Int {
    let pageWidth = scrollView.frame.height
    return Int(floor(1-((offset.y)/pageWidth)))
  }
  private(set) var currentPage : Int = 1
  func set(newCurrentPage : Int) {
    if newCurrentPage >= 0, newCurrentPage < buttons.count {
      currentPage = newCurrentPage
      scrollView.setContentOffset(CGPoint.init(x: 0, y: CGFloat(newCurrentPage)*scrollView.frame.height), animated: true)
    }
  }
  
  
  @objc func buttonHit(sender : UIButton) {
    // TODO: Implement Go-To-Button-Tapped
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
        newButton.setImage(buttonIcons[bNum], for: .normal)  
        newButton.tintColor = RMColor.AppColor
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
       canvasViews[bNum]?.layoutSubviews() 
      }
    }
    scrollView.contentSize = CGSize.init(width: scrollView.bounds.width/2, height: CGFloat(buttonIcons.count)*scrollView.bounds.height)
    scrollView.contentOffset = CGPoint.init(x: 0, y: scrollView.bounds.height * CGFloat(currentPage))
  }
  
//  
//  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    let pageWidth = scrollView.bounds.height
//    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
//    currentPage = Int(page)
//  }
//  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//    let pageWidth = scrollView.frame.height
//    let page = floor((scrollView.contentOffset.y - pageWidth/2)/pageWidth) + 1
//    currentPage = Int(page)
//  }
  override func viewDidLayoutSubviews() {
    _ = setupScrollView
    adjustScrollView()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { (_) in
      for canvasView in self.canvasViews {
       canvasView?.removeFromSuperview() 
      }
      self.canvasViews = [UIView?](repeating: nil, count: self.buttonIcons.count)
      self.adjustScrollView()
      if self.isViewLoaded {
        if size.height < size.width {
          UIView.animate(withDuration: RMAnimation.ColoringTime, animations: { 
            self.rushMeLogo.alpha = 0
          }, completion: { (_) in
            self.rushMeLogo.isHidden = true
          })
        }
        else {
          self.rushMeLogo.alpha = 0
          self.rushMeLogo.isHidden = false
          UIView.animate(withDuration: RMAnimation.ColoringTime, animations: { 
            self.rushMeLogo.alpha = 1
          }, completion: nil)
        }
      }
      
    }
    super.viewWillTransition(to: size, with: coordinator)
  }
}






