//
//  DetailViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//


import UIKit
import MapKit

// TODO: Allow users to swipe between fraternities
class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate {
  // MARK: IBOutlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var underlyingView: UIView!
  @IBOutlet weak var coverImageView: UIView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var underProfileLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var memberCountLabel: UILabel!
  @IBOutlet weak var staticMemberLabel: UILabel!
  @IBOutlet weak var gpaLabel: UILabel!
  @IBOutlet weak var staticGPALabel: UILabel!
  @IBOutlet weak var favoritesButton: UIBarButtonItem!
  @IBOutlet weak var eventView: UIView!
  @IBOutlet weak var blockTextView: UITextView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var openMapButton: UIButton!
  @IBOutlet var toMakeClear: [UIView]!
  var coverImagePageViewController : ImagePageViewController {
    get {
      return (self.childViewControllers.first as! ImagePageViewController)
    }
  }
  
  
  var openInMapsAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Open in Maps", style: .default, handler: { (_) in
        MKMapItem.openMaps(with: [self.mapItem!], launchOptions: nil)
      }) 
    }
  }
  var getDirectionsInMapsAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Get Directions", style: .default, handler: { (_) in
        MKMapItem.openMaps(with: [self.mapItem!], launchOptions: [MKLaunchOptionsDirectionsModeKey : true])
      }) 
    }
  }
  var cancelAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
  }
  // MARK: Member Variables
  weak var eventViewController : EventTableViewController? = nil
  var mapItem : MKMapItem?
  var selectedFraternity: Fraternity? = nil {
    didSet {
      if let frat = selectedFraternity {
        eventViewController?.selectedEvents = Array(frat.events.values)
        self.title = frat.name.greekLetters
      }
    }
  }
  // MARK: IBActions
  @IBAction func favoritesButtonHit(_ sender: UIBarButtonItem) {
    if let fratName = selectedFraternity?.name {
      if let _ = Campus.shared.favoritedFrats.index(of: fratName) {
        Campus.shared.removeFavorite(named: fratName)
        favoritesButton.image = RMImage.FavoritesImageUnfilled
        self.profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        //SQLHandler.shared.informAction(action: "Fraternity Unfavorited in DetailVC", options: fratName)
      }
      else {
        Campus.shared.addFavorite(named: fratName)
        favoritesButton.image = RMImage.FavoritesImageFilled
        self.profileImageView.layer.borderColor = RMColor.AppColor.withAlphaComponent(0.7).cgColor
        //SQLHandler.shared.informAction(action: "Fraternity Unfavorited in DetailVC", options: fratName)
      }
    }
  }
  // Would like to add 3D touch support
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
    if let imageVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageVC") as? ImageViewController {
      if profileImageView.frame.contains(sender.location(in: view)),
        let image = profileImageView.image{
        imageVC.image = image
      }
      else if let image = coverImagePageViewController.currentPageImage {
        imageVC.image = image
      }
      _ = imageVC.image != RMImage.NoImage ? self.present(imageVC, animated: true, completion: {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }) : nil
      
    }
}
@IBAction func coverImagePinched(_ sender: UIPinchGestureRecognizer) {
  if sender.state == .began || sender.state == .changed {
    guard let senderView = sender.view as? UIImageView, 
      senderView.image != RMImage.NoImage else { return }
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
@IBAction func openInMaps(_ sender: UIButton) {
  if let _ = mapItem { 
    let addressAlert = UIAlertController.init(title: selectedFraternity?.name, message: selectedFraternity?.getProperty(named: RMDatabaseKey.AddressKey) as? String, preferredStyle: .actionSheet)
    addressAlert.view.tintColor = RMColor.AppColor
    addressAlert.addAction(openInMapsAction)
    addressAlert.addAction(getDirectionsInMapsAction)
    addressAlert.addAction(cancelAction)
    self.present(addressAlert, animated: true, completion: nil)
  }
}
// MARK: Set View Alphas
func setViews(toAlpha : CGFloat, except exceptedView : UIView? = nil) {
  let underlyingViews = [self.coverImageView, self.profileImageView, self.titleLabel,
                         self.eventView, self.blockTextView, self.underProfileLabel,
                         self.gpaLabel, self.memberCountLabel, self.staticGPALabel, self.staticMemberLabel]
  for view in underlyingViews {
    if let _ = view, view != exceptedView {
      view!.alpha = toAlpha
    }
  }
  for view in toMakeClear {
    view.alpha = toAlpha
  }
}
override func awakeFromNib() {
  
}

// MARK: ViewDidLoad
override func viewDidLoad() {
  super.viewDidLoad()
  self.view.bringSubview(toFront: coverImageView)
  self.view.bringSubview(toFront: profileImageView)
  coverImageView.layer.masksToBounds = true
  //coverImageView.clipsToBounds = false
  coverImageView.contentMode = UIViewContentMode.scaleAspectFill
  profileImageView.layer.masksToBounds = false
  profileImageView.clipsToBounds = true
  //profileImageView.contentMode = UIViewContentMode.scaleAspectFill
  
  profileImageView.layer.cornerRadius = RMImage.CornerRadius
  profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
  profileImageView.layer.borderWidth = 1
  profileImageView.setNeedsDisplay()
  if let tbView = self.childViewControllers.last as? EventTableViewController {
    eventViewController = tbView
  }
  mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
  //blockTextView.isScrollEnabled = false
  //blockTextView.isEditable = false
  //scrollView.isScrollEnabled = true
  eventViewController!.view.layer.masksToBounds = true
  mapView.layer.cornerRadius = 5
  mapView.layer.masksToBounds = true
  //openMapButton.tintColor = UIColor.white
  //openMapButton.layer.cornerRadius = 5
  //openMapButton.layer.masksToBounds = true
  //openMapButton.addSubview(visualEffectView)
  //openMapButton.sendSubview(toBack: visualEffectView)
  //self.underlyingView.bringSubview(toFront: mapView)
  //self.underlyingView.bringSubview(toFront: openMapButton)
  // Do any additional setup after loading the view, typically from a nib.
  DispatchQueue.global(qos: .utility).async {
    if let frat = self.selectedFraternity {
      if let event = Campus.shared.getEvents(forFratWithName: frat.name).filter({ (key, value) -> Bool in
        return Campus.shared.considerEventsBeforeToday || value.startDate.compare(RMDate.Today) != .orderedAscending
      }).last?.value {
        DispatchQueue.main.async {
          self.eventViewController!.selectedEvents = [event]
          self.eventViewController!.provideDate = true
        }
      }
      else {
        DispatchQueue.main.async {
          self.eventViewController!.selectedEvents = nil
        }
      }
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
// MARK: ConfigureView
func configureView() {
  if let frat = selectedFraternity {
    // Update the user interface for the detail item.
    if let calendarImageURL = frat.getProperty(named: RMDatabaseKey.CalendarImageKey) as? String {
      //self.coverImageView.setImageByURL(fromSource: coverImageURL)
      (self.childViewControllers.first as? ImagePageViewController)?.imageNames = [calendarImageURL] 
    }
    if let coverImageURL = frat.getProperty(named: RMDatabaseKey.CoverImageKey) as? String {
      (self.childViewControllers.first as? ImagePageViewController)?.imageNames.append(coverImageURL)
    }
    if frat.previewImage == RMImage.NoImage {
      self.profileImageView.isUserInteractionEnabled = false 
    }
    else {
      self.profileImageView?.image = frat.previewImage
    }
    self.titleLabel?.text = frat.name
    self.title = frat.name.greekLetters
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
    if let address = frat.getProperty(named: RMDatabaseKey.AddressKey) as? String {
      DispatchQueue.global().async {
        
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
    }
    else {
      self.mapView?.removeFromSuperview()
      self.openMapButton?.isHidden = true
    }
    
    
    
  }
  
}
override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
  // Dispose of any resources that can be recreated.
}
}

extension UIImageView {
  func setImageByURL(fromSource imageURL : String) {
    // Set an imageView's image asynchronously, allowing rest of page to be loaded
    DispatchQueue.global(qos: .background).async {
      // Try to load the image
      if let downloadedImage = pullImage(fromSource: imageURL) {
        DispatchQueue.main.async {
          // Image loaded, set it in main thread
          self.image = downloadedImage
          self.isUserInteractionEnabled = true
        }
      }
      else {
        DispatchQueue.main.async{
          // Image could not be loaded, set image to default image
          self.image = RMImage.NoImage 
          self.isUserInteractionEnabled = false
        }
      }
    }
  }
}

extension UIMotionEffect {
  class func twoAxesShift(strength: Float) -> UIMotionEffect {
    // internal method that creates motion effect
    func motion(type: UIInterpolatingMotionEffectType) -> UIInterpolatingMotionEffect {
      let keyPath = type == .tiltAlongHorizontalAxis ? "center.x" : "center.y"
      let motion = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
      motion.minimumRelativeValue = -strength
      motion.maximumRelativeValue = strength
      return motion
    }
    
    // group of motion effects
    let group = UIMotionEffectGroup()
    group.motionEffects = [
      motion(type: .tiltAlongHorizontalAxis),
      motion(type: .tiltAlongVerticalAxis)
    ]
    return group
  }
}



