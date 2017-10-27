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
  @IBOutlet var titleLabel: UILabel!
  
  //@IBOutlet var favoriteButton: UIButton!
  @IBOutlet var aboveTextLabel: UILabel!
  
  @IBOutlet var blockTextView: UITextView!
  @IBOutlet var addressBox: UITextView!
  
  var selectedFraternity: Fraternity? {
    didSet {
      // Update the view.
      configureView()
    }
  }
  
  func configureView() {
  
    if let frat = selectedFraternity {
      // Update the user interface for the detail item.
      self.titleLabel?.text = frat.name
      self.title = greekLetters(inString: frat.name)
      self.underProfileLabel?.text = frat.chapter + " Chapter"
      if let desc = frat.getProperty(named: "description") as? String {
        if let textView = blockTextView {
          textView.text = desc
          textView.sizeToFit()
          scrollView?.isScrollEnabled = true
          scrollView?.contentSize = textView.contentSize
          //underlyingView?.frame.size = textView.contentSize
          self.view.layoutSubviews()
          
        }
      }
      if let coverImage = frat.getProperty(named: "coverImage") as? UIImage {
        self.coverImageView?.image = coverImage
        self.coverImageView?.layer.shadowOpacity = 0.5
      }
      if let profileImage = frat.getProperty(named: "profileImage") as? UIImage {
        self.profileImageView?.image = profileImage
        self.profileImageView?.layer.shadowOpacity = 0.5
      }
      if let address = frat.getProperty(named: "address") as? String {
        self.addressBox?.text = address
      }
      else {
        self.addressBox?.isHidden = true
        self.aboveTextLabel?.isHidden = true
      }
    }
    
    
   
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.bringSubview(toFront: coverImageView)
    self.view.bringSubview(toFront: profileImageView)
    
    coverImageView.image = IMAGE_CONST.NO_IMAGE
    coverImageView.layer.masksToBounds = false
    coverImageView.clipsToBounds = true
    coverImageView.contentMode = UIViewContentMode.scaleAspectFill
    coverImageView.layer.shadowRadius = 20
    coverImageView.layer.shadowOpacity = 0
    coverImageView.layer.shadowColor = UIColor.black.cgColor
    
    profileImageView.image = IMAGE_CONST.NO_IMAGE
    profileImageView.layer.masksToBounds = false
    profileImageView.clipsToBounds = true
    profileImageView.contentMode = UIViewContentMode.scaleAspectFill
    profileImageView.layer.shadowRadius = 10
    profileImageView.layer.cornerRadius = IMAGE_CONST.CORNER_RADIUS
    profileImageView.layer.shadowOpacity = 0.5
    profileImageView.layer.shadowColor = UIColor.black.cgColor
    profileImageView.layer.borderColor = UIColor.white.cgColor
    profileImageView.layer.borderWidth = 1
    profileImageView.setNeedsDisplay()
    
    
    
    blockTextView.isScrollEnabled = false
    blockTextView.isEditable = false
    scrollView.isScrollEnabled = true
    //scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.addressBox.frame.maxY + 8)
    //scrollView.sizeToFit()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  

  
  
  
}


