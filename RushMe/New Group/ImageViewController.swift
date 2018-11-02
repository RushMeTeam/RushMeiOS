//
//  ImageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/30/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
  var image : UIImage = UIImage() {
    willSet {
      self.loadViewIfNeeded()
      self.imageView.image = newValue 
    }
  }
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!
  var visualEffectView : UIVisualEffectView?
  override func viewDidLoad() {
    super.viewDidLoad()
    self.visualEffectView?.removeFromSuperview()
    self.view.backgroundColor = UIColor.clear
    self.scrollView.maximumZoomScale = 3
    self.scrollView.minimumZoomScale = 1
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.alwaysBounceVertical = true
    self.scrollView.isScrollEnabled = true
    self.scrollView.delegate = self
    self.scrollView.contentSize = imageView.frame.size
    self.scrollView.bounces = true
  }
  func addVisualEffectView() {
    visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.light))
    visualEffectView!.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(visualEffectView!)
    self.view.sendSubviewToBack(visualEffectView!)
    NSLayoutConstraint.activate([visualEffectView!.topAnchor.constraint(equalTo: view.topAnchor),
                                 visualEffectView!.leftAnchor.constraint(equalTo: view.leftAnchor),
                                 visualEffectView!.rightAnchor.constraint(equalTo: view.rightAnchor),
                                 visualEffectView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.imageView?.image = image
    self.imageView?.layer.masksToBounds = true
    self.imageView?.layer.cornerRadius = Frontend.cornerRadius
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.zoomScale < 1.1 && abs(scrollView.contentOffset.y) > view.frame.height/5.5 {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    if (scrollView.zoomScale < 0.75) {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

extension UIStoryboard {
  var imageVC : ImageViewController {
    return instantiateViewController(withIdentifier: "imageVC") as! ImageViewController 
  }
}
