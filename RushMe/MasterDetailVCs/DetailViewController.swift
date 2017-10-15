//
//  DetailViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//


import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var underlyingView: UIView!
  @IBOutlet var coverImageView: UIImageView!
  @IBOutlet var profileImageView: UIImageView!
  @IBOutlet var underProfileLabel: UILabel!
  
  //@IBOutlet var favoriteButton: UIButton!
  @IBOutlet var aboveTextLabel: UILabel!
  
  @IBOutlet var blockTextView: UITextView!
  
  func configureView() {
  
    // Update the user interface for the detail item.
    self.title = selectedFraternity?.name
    self.underProfileLabel?.text = selectedFraternity?.chapter
    self.blockTextView?.text = selectedFraternity?.description
    self.coverImageView?.image = selectedFraternity?.coverPhoto
    self.profileImageView?.image = selectedFraternity?.profilePhoto
    if (self.profileImageView?.image == nil){
      self.profileImageView?.image = IMAGE_CONST.NO_IMAGE
    }
    if (self.coverImageView?.image == nil) {
      self.coverImageView?.image = IMAGE_CONST.NO_IMAGE
    }
    
  }
  
  
  
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    self.view.bringSubview(toFront: coverImageView)
    self.view.bringSubview(toFront: profileImageView)
    coverImageView.layer.masksToBounds = false
    coverImageView.contentMode = UIViewContentMode.scaleAspectFill
    coverImageView.layer.shadowRadius = 20
    coverImageView.layer.shadowOpacity = 1
    coverImageView.layer.shadowColor = UIColor.black.cgColor
    coverImageView.setNeedsDisplay()
    
    profileImageView.layer.masksToBounds = false
    profileImageView.contentMode = UIViewContentMode.scaleAspectFill
    profileImageView.layer.shadowRadius = 10
    profileImageView.layer.shadowOpacity = 0.5
    profileImageView.layer.shadowColor = UIColor.black.cgColor
    profileImageView.setNeedsDisplay()
    
    scrollView.sizeToFit()
    
    blockTextView.isScrollEnabled = false
    blockTextView.isEditable = false
    var size_ = blockTextView.intrinsicContentSize
    size_.width = blockTextView.frame.width
    blockTextView.frame.size = size_
    blockTextView.layoutIfNeeded()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  var selectedFraternity: Fraternity? {
    didSet {
      // Update the view.
      configureView()
    }
  }

  
  
  
}


