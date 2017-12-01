//
//  DetailViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//


import UIKit
import MapKit

class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate {
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var underlyingView: UIView!
  @IBOutlet var coverImageView: UIImageView!
  @IBOutlet var profileImageView: UIImageView!
  @IBOutlet var underProfileLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  
  @IBOutlet weak var memberCountLabel: UILabel!
  @IBOutlet weak var staticMemberLabel: UILabel!
  @IBOutlet weak var gpaLabel: UILabel!
  @IBOutlet weak var staticGPALabel: UILabel!
  
  
  @IBOutlet weak var favoritesButton: UIBarButtonItem!
  @IBOutlet weak var eventView: UIView!
  var eventViewController : EventTableViewController? = nil
  
  @IBOutlet var blockTextView: UITextView!
  
  var mapItem : MKMapItem?
  @IBOutlet weak var mapView: MKMapView!
  var selectedFraternity: Fraternity? {
    didSet {
      eventViewController?.selectedEvents = Array(selectedFraternity!.events.values)
    }
  }
  @IBOutlet weak var openMapButton: UIButton!
  
  @IBAction func favoritesButtonHit(_ sender: UIBarButtonItem) {
    if let frat = self.selectedFraternity {
      if let index = Campus.shared.favoritedFrats.index(of: frat.name) {
        Campus.shared.favoritedFrats.remove(at: index)
        favoritesButton.image = RMImage.FavoritesImageUnfilled
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
          self.profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        })
      }
      else {
        Campus.shared.favoritedFrats.append(frat.name)
        favoritesButton.image = RMImage.FavoritesImageFilled
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
          self.profileImageView.layer.borderColor = RMColor.AppColor.withAlphaComponent(0.7).cgColor
        })
        
      }
    }
  }
  
  
  @IBAction func coverImageTapped(_ sender: UITapGestureRecognizer) {
    sender.view?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)

    UIView.animate(withDuration: RMAnimation.ColoringTime*2,
                   delay: 0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 30,
                   options: .allowUserInteraction,
                   animations: {
      sender.view?.transform = CGAffineTransform.identity
    }, completion: { _ in

    })
    if let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "imageVC") as? ImageViewController {
      if let img = (sender.view as! UIImageView).image {
        imageVC.image = img
      }
      self.present(imageVC, animated: true, completion: {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        
      })
    }
  }
  @IBAction func coverImagePinched(_ sender: UIPinchGestureRecognizer) {
    if sender.state == .began || sender.state == .changed {
      guard let senderView = sender.view else { return }
      self.scrollView.isScrollEnabled = false
      let currScale = senderView.frame.size.width/senderView.bounds.size.width
      var newScale = currScale*sender.scale
      var maxScale : CGFloat = 2
      if (sender.view == self.profileImageView) {
       maxScale = (self.view.bounds.width*0.9)/senderView.bounds.width
      }
      let minScale : CGFloat = 1
      newScale = max(newScale, minScale) // MIN SCALE
      newScale = min(newScale, maxScale)
      if newScale == 1 {
       return
      }
      let overTime = min(pow(((1-newScale)*(1-6)), 2), 1)
      let location = sender.location(in: self.view)
      var transform = CGAffineTransform(scaleX: newScale, y: newScale)
      var pinchCenter = CGPoint(x: (location.x - senderView.bounds.midX)*overTime*1.5,
                                y: (location.y - senderView.bounds.midY)*overTime*1.5)
      
      if senderView == self.profileImageView {
          pinchCenter = CGPoint(x: (self.view.frame.width/2 - senderView.bounds.midX)*overTime/newScale,
                              y: 0)
      }
      else {
       senderView.clipsToBounds = false
      }
      transform = transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
      senderView.transform = transform
      //senderView.layer.shadowColor = UIColor.black.cgColor
      senderView.layer.shadowOpacity = Float(overTime)
      senderView.layer.shadowRadius = (overTime)*10.0
      if (senderView != self.profileImageView) {
        self.setViews(toAlpha: 1 - overTime, except: senderView)
      }
      
      sender.scale = 1
      
    }
    else {
      self.scrollView.isScrollEnabled = true
      UIView.animate(withDuration: RMAnimation.ColoringTime/2, animations: {
        sender.view?.transform = CGAffineTransform.identity
        sender.view?.layer.shadowOpacity = 0
        sender.view?.clipsToBounds = true
        self.setViews(toAlpha: 1)
      }, completion: { _ in
       
        
      })
     
      
    }
  }
  
  func setViews(toAlpha : CGFloat, except exceptedView : UIView? = nil) {
    let underlyingViews = [self.coverImageView, self.profileImageView, self.titleLabel,
                           self.eventView, self.blockTextView, self.underProfileLabel,
                           self.gpaLabel, self.memberCountLabel, self.staticGPALabel, self.staticMemberLabel]
    for view in underlyingViews {
      if let _ = view, view != exceptedView {
       view!.alpha = toAlpha
      }
    }
  }

  
  @IBAction func openInMaps(_ sender: UIButton) {
    if let _ = mapItem { MKMapItem.openMaps(with: [mapItem!], launchOptions: nil) }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.bringSubview(toFront: coverImageView)
    self.view.bringSubview(toFront: profileImageView)
    
    coverImageView.image = RMImage.NoImage
    coverImageView.layer.masksToBounds = true
    
    coverImageView.clipsToBounds = false
    coverImageView.contentMode = UIViewContentMode.scaleAspectFill
    coverImageView.layer.shadowRadius = 20
    coverImageView.layer.shadowOpacity = 0
    coverImageView.layer.shadowColor = UIColor.black.cgColor
    
    profileImageView.image = RMImage.NoImage
    profileImageView.layer.masksToBounds = false
    profileImageView.clipsToBounds = true
    profileImageView.contentMode = UIViewContentMode.scaleAspectFill
    profileImageView.layer.cornerRadius = RMImage.CornerRadius
    profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
    profileImageView.layer.borderWidth = 1
    profileImageView.setNeedsDisplay()
    
    if let tbView = self.childViewControllers.first as? EventTableViewController {
      eventViewController = tbView
    }
    mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
    mapView.showsBuildings = true
    mapView.mapType = .hybrid
    mapView.showsCompass = false
    mapView.isZoomEnabled = false
    mapView.isScrollEnabled = false
    blockTextView.isScrollEnabled = false
    blockTextView.isEditable = false
    scrollView.isScrollEnabled = true
    eventViewController!.view.layer.shadowColor = UIColor.black.cgColor
    eventViewController!.view.layer.shadowRadius = 10
    eventViewController!.view.layer.shadowOpacity = 0.7
    eventViewController!.view.layer.masksToBounds = false
    eventViewController!.view.layer.cornerRadius = 5
    mapView.layer.shadowColor = UIColor.black.cgColor
    mapView.layer.shadowRadius = 10
    mapView.layer.shadowOpacity = 0.7
    mapView.layer.masksToBounds = false
    openMapButton.tintColor = RMColor.AppColor
    openMapButton.backgroundColor = RMColor.AppColor.withAlphaComponent(0.5)
    openMapButton.layer.cornerRadius = 5
    openMapButton.layer.masksToBounds = true
    
    self.underlyingView.bringSubview(toFront: mapView)
    self.underlyingView.bringSubview(toFront: openMapButton)
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
    if let frat = selectedFraternity {
      if let event = Array(Campus.shared.getEvents(forFratWithName: frat.name)).filter({ (key, value) -> Bool in
        return Campus.shared.considerEventsBeforeToday || value.startDate.compare(RMDate.Today) != .orderedAscending
      }).last?.value {
        eventViewController?.selectedEvents = [event]
      }
      else {
        eventViewController?.selectedEvents = nil
      }
    }
    self.profileImageView.layer.zPosition = 10
    self.scrollView.canCancelContentTouches = true
    self.coverImageView.clipsToBounds = true
    
    self.configureView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.profileImageView.transform = CGAffineTransform.identity
    self.profileImageView.alpha = 1
    self.coverImageView.transform = CGAffineTransform.identity
    self.coverImageView.alpha = 1
  }
  
  func configureView() {
    if let frat = selectedFraternity {
      // Update the user interface for the detail item.
      self.titleLabel?.text = frat.name
      self.title = greekLetters(fromString: frat.name)
      self.underProfileLabel?.text = frat.chapter + " Chapter"
      self.gpaLabel?.text = frat.getProperty(named: RMDatabaseKey.gpaKey) as? String
      if let _ = self.gpaLabel?.text {
        self.gpaLabel!.text = String(describing: self.gpaLabel!.text!.dropLast())
      }
      if let memberCount = frat.getProperty(named: RMDatabaseKey.MemberCountKey) as? Int {
        self.memberCountLabel?.text = String(describing: memberCount)
      }
      
      if Campus.shared.favoritedFrats.contains(frat.name) {
        self.favoritesButton.image = RMImage.FavoritesImageFilled
        self.profileImageView?.layer.borderColor = RMColor.AppColor.withAlphaComponent(0.7).cgColor
      }
      else {
        self.favoritesButton.image = RMImage.FavoritesImageUnfilled
        self.profileImageView?.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
      }
      if let desc = frat.getProperty(named: RMDatabaseKey.DescriptionKey) as? String {
        if let textView = blockTextView {
          textView.text = desc
          textView.sizeToFit()
          scrollView?.isScrollEnabled = true
          scrollView?.contentSize = textView.contentSize
          //underlyingView?.frame.size = textView.contentSize
          self.view.layoutSubviews()
          
        }
      }
      if let coverImage = frat.getProperty(named: RMDatabaseKey.CoverImageKey) as? UIImage {
        self.coverImageView?.image = coverImage
      }
      else if let coverImage = frat.getProperty(named: RMDatabaseKey.CalendarImageKey) as? UIImage {
        self.coverImageView?.image = coverImage
        //self.coverImageView?.layer.shadowOpacity = 0.5
      }
      if let profileImage = frat.getProperty(named: RMDatabaseKey.ProfileImageKey) as? UIImage {
        self.profileImageView?.image = profileImage
        //self.profileImageView?.layer.shadowOpacity = 0.5
      }
      else if let previewImage = frat.getProperty(named: RMDatabaseKey.PreviewImageKey) as? UIImage {
        self.profileImageView?.image = previewImage
      }
      if let address = frat.getProperty(named: RMDatabaseKey.AddressKey) as? String {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address, completionHandler: {
          (placemarks, error) in
          guard
            let placemarks = placemarks,
            let location = placemarks.first?.location
            
            else {
              // handle no location found
              return
          }
          // Use your location
          let annotation = MKPointAnnotation.init()
          self.mapItem = MKMapItem.init(placemark: MKPlacemark.init(coordinate: location.coordinate))
          self.mapItem?.name = frat.name
          
          annotation.coordinate = location.coordinate
          annotation.title = frat.name
          annotation.subtitle = address
          
          self.mapView.setCenter(annotation.coordinate, animated: false)
          self.mapView.addAnnotation(annotation)
        })
      }
      else {
        self.mapView?.isHidden = true
        self.openMapButton?.isHidden = true
      }
    }
    coverImageView?.isUserInteractionEnabled = coverImageView.image != RMImage.NoImage
    profileImageView?.isUserInteractionEnabled = profileImageView.image != RMImage.NoImage
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}


