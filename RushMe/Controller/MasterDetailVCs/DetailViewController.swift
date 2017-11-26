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
  @IBOutlet weak var gpaLabel: UILabel!
  
  
  @IBOutlet weak var favoritesButton: UIBarButtonItem!
  @IBOutlet weak var eventView: UIView!
  var eventViewController : EventTableViewController? = nil
  
  @IBOutlet var blockTextView: UITextView!
  
  var mapItem : MKMapItem?
  @IBOutlet weak var mapView: MKMapView!
  var selectedFraternity: Fraternity? {
    didSet {
      // Update the view.
      configureView()
      eventViewController?.selectedEvents = Array(selectedFraternity!.events.values)
    }
  }
  @IBOutlet weak var openMapButton: UIButton!
  
  @IBAction func favoritesButtonHit(_ sender: UIBarButtonItem) {
    if let frat = self.selectedFraternity {
      if let index = Campus.shared.favoritedFrats.index(of: frat.name) {
        Campus.shared.favoritedFrats.remove(at: index)
        favoritesButton.image = RMImage.FavoritesImageUnfilled
      }
      else {
        Campus.shared.favoritedFrats.append(frat.name)
        favoritesButton.image = RMImage.FavoritesImageFilled
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
    coverImageView.layer.masksToBounds = false
    coverImageView.clipsToBounds = true
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
      if let event = Array(Campus.shared.getEvents(forFratWithName: frat.name)).last?.value {
        eventViewController?.selectedEvents = [event]
      }
      else {
        eventViewController?.selectedEvents = nil
      }
    }
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
      }
      else {
        self.favoritesButton.image = RMImage.FavoritesImageUnfilled
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
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}


