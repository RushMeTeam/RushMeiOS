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
  
    if let frat = selectedFraternity {
      
      
      // Update the user interface for the detail item.
      self.title = frat.name
      self.underProfileLabel?.text = frat.chapter
      if let desc = frat.getProperty(named: "description") as? String {
        self.blockTextView?.text = desc
      }
      if let coverImage = frat.getProperty(named: "coverImage") as? UIImage {
        self.coverImageView?.image = coverImage
        self.coverImageView?.layer.shadowOpacity = 0.5
      }
      if let profileImage = frat.getProperty(named: "profileImage") as? UIImage {
        self.profileImageView?.image = profileImage
        self.profileImageView?.layer.shadowOpacity = 0.5
      }
    }
  }
  
  
  
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    self.view.bringSubview(toFront: coverImageView)
    self.view.bringSubview(toFront: profileImageView)
    coverImageView.image = IMAGE_CONST.NO_IMAGE
    coverImageView.layer.masksToBounds = false
    coverImageView.contentMode = UIViewContentMode.scaleAspectFill
    coverImageView.layer.shadowRadius = 20
    coverImageView.layer.shadowOpacity = 0
    coverImageView.layer.shadowColor = UIColor.black.cgColor
    coverImageView.setNeedsDisplay()
    
    profileImageView.image = IMAGE_CONST.NO_IMAGE
    profileImageView.layer.masksToBounds = false
    profileImageView.contentMode = UIViewContentMode.scaleAspectFill
    profileImageView.layer.shadowRadius = 10
    profileImageView.layer.shadowOpacity = 0
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


