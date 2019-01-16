//
//  DetailViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//


import UIKit
import MapKit

class DetailViewController: UIViewController, 
UIScrollViewDelegate, 
MKMapViewDelegate, 
UIViewControllerPreviewingDelegate {  
  
  // MARK: IBOutlets
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var underlyingView: UIView!
  @IBOutlet weak var coverImageView: UIView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var underProfileLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var memberCountLabel: UILabel!
  @IBOutlet weak var blockTextView: UITextView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var openMapButton: UIButton!
  
  // MARK: Member Variables
  @IBOutlet weak var eventView: UIView!
  var mapItem : MKMapItem! {
    get {
      guard let frat = selectedFraternity,
            let coordinates = frat.coordinates else {
       return nil 
      }
      
      let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
      item.name = frat.name
      return item
    }
  }
  var favoritesButton = UIBarButtonItem(image: Frontend.images.unfilledHeart, 
                                        style: .plain, 
                                        target: self, 
                                        action: #selector(favoritesButtonHit))
  var newImageViewController : ImageViewController? {
    get {
      return UIStoryboard.main.imageVC
    }
  }
  private var coverImagePageViewController : ImagePageViewController!
  
  var openInMapsAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Open in Maps", style: .default, handler: { (_) in
        MKMapItem.openMaps(with: [self.mapItem!], launchOptions: nil)
      }) 
    }
  }
  lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
  
  private var _eventViewController : EventTableViewController? 
  var eventViewController : EventTableViewController! {
    get {
      guard let _ = _eventViewController else {
        _eventViewController = children.first(where: { (child) -> Bool in
          return child is EventTableViewController
        }) as? EventTableViewController
        return _eventViewController
      }
      return _eventViewController
    }
  }
  
  var selectedFraternity: Fraternity? = nil {
    didSet {
      if let events = selectedFraternity?.events {
        eventViewController?.selectedEvents = events
      }
      title = selectedFraternity?.name.greekLetters
    }
  }
  
  // MARK: IBActions
  @objc func favoritesButtonHit(_ sender: UIBarButtonItem) {
    guard let frat = selectedFraternity else { return }
    if frat.isFavorite {
      _ = Campus.shared.unfavorite(frat: frat)
      sender.image = Frontend.images.unfilledHeart
      self.profileImageView.layer.borderColor = 
        UIColor.white.withAlphaComponent(0.7).cgColor
    } else {
      _ = Campus.shared.favorite(frat: frat)
      sender.image = Frontend.images.filledHeart
      self.profileImageView.layer.borderColor = 
        Frontend.colors.AppColor.withAlphaComponent(0.7).cgColor
    }
  }
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, 
                         viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard profileImageView.point(inside: location, with: nil), 
          let imageVC = newImageViewController,
          let image = profileImageView.image else { return nil }
    imageVC.image = image
    return imageVC
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, 
                         commit viewControllerToCommit: UIViewController) {
    present(viewControllerToCommit, animated: true) {
      (viewControllerToCommit as? ImageViewController)?.addVisualEffectView()
    }
  }
  
  override var previewActionItems: [UIPreviewActionItem] {
    get {
      var message = "Favorite"
      if let favorited = selectedFraternity?.isFavorite, favorited {
          message = "Unfavorite"
      }
      return [UIPreviewAction(title: message, style: .default) { (_, _) in }]
    }
  }
  // Would like to add 3D touch support
  @IBAction func coverImageTapped(_ sender: UITapGestureRecognizer) {
    sender.view?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
    UIView.animate(withDuration: Frontend.animations.defaultDuration*2,
                   delay: 0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 30,
                   options: .allowUserInteraction,
                   animations: { sender.view?.transform = CGAffineTransform.identity }, 
                   completion: nil)
    guard let imageVC = newImageViewController else { return }
    
    if profileImageView.frame.contains(sender.location(in: view)),
      let image = profileImageView.image {
      imageVC.image = image
      
      
    } else if let image = coverImagePageViewController.currentPageImage {
      imageVC.image = image
    }

    guard imageVC.image.size != .zero && 
          imageVC.image != Frontend.images.noImage else { return }
    imageVC.addVisualEffectView()
    present(imageVC, animated: true, completion: nil)
  }
  
  @IBAction func openInMaps(_ sender: UIButton) {
    guard let _ = mapItem, let frat = selectedFraternity else { return   }
    let addressAlert = UIAlertController.init(title: frat.name, 
                                              message: frat.address, 
                                              preferredStyle: .actionSheet)
    addressAlert.view.tintColor = Frontend.colors.AppColor
    addressAlert.addAction(openInMapsAction)
    addressAlert.addAction(cancelAction)
    self.present(addressAlert, animated: true, completion: nil)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    _ = setupViews
    _ = configureView
  }
  
  
  lazy var setupProfileImageView : Void = {
    profileImageView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    profileImageView.layer.zPosition = -1
  }()
  lazy var setupCoverImageView : Void = {
    coverImageView.layer.masksToBounds = true
    coverImageView.contentMode = UIView.ContentMode.scaleAspectFill
    coverImageView.layer.masksToBounds = true
    coverImageView.layer.cornerRadius = Frontend.cornerRadius
    coverImageView.clipsToBounds = true
    coverImageView.layer.zPosition = 9
  }()
  
  lazy var setupViews : Void = {
    _ = setupProfileImageView
    _ = setupCoverImageView
    view.bringSubviewToFront(coverImageView)
    view.bringSubviewToFront(profileImageView)
    scrollView.canCancelContentTouches = true
    mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    view.backgroundColor = .clear
    parent?.view.backgroundColor = Frontend.colors.NavigationBarColor
  }()
  // MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    // Enable 3D touch on the profile image
    registerForPreviewing(with: self, sourceView: profileImageView)
     
  }
  
  lazy var configureView : Void = {
    guard let frat = selectedFraternity else {
      print("No Frat to configure view with!")
      return
    }
    
    if let imageVC = children.first as? ImagePageViewController {
      imageVC.imageNames = []
      // Update the user interface for the detail item.
      if let calendarImageURL = frat.calendarImagePath {
        //self.coverImageView.setImageByURL(fromSource: coverImageURL)
        imageVC.imageNames.append(calendarImageURL)
      }
      imageVC.imageNames.append(contentsOf: frat.coverImagePaths)
    }
    
    if let _ = frat.profileImagePath {
      profileImageView.setImage(with: frat.profileImagePath)
    }
    
    
    titleLabel.text = frat.name
    underProfileLabel.text = frat.chapter + " Chapter"
    if let memberCount = frat.memberCount {
      self.memberCountLabel.text = String(describing: memberCount) + " Members"
    }
    let favoritesImage = frat.isFavorite ? Frontend.images.filledHeart : 
                                           Frontend.images.unfilledHeart
    favoritesButton.image = favoritesImage
    profileImageView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    
    
    
    
    
    favoritesButton.title = frat.name
    blockTextView.text = frat.description
    blockTextView.sizeToFit()
    
    
    
    scrollView.isScrollEnabled = true
    
    if let location = frat.coordinates {
      let annotation = MKPointAnnotation()
      annotation.coordinate = location
      annotation.title = frat.name
      annotation.subtitle = frat.address
      mapView.addAnnotation(annotation)
      mapView.setCenter(annotation.coordinate, animated: false)
    } else {
      self.mapView.isScrollEnabled = false
      self.mapView.setCenter(defaultCoordinates, animated: false)
    }
    // Do any additional setup after loading the view, typically from a nib.
    DispatchQueue.global(qos: .utility).async {
      guard let event = frat.events?.filter({ (value) -> Bool in
        return User.preferences.considerPastEvents || value.starting.compare(.today) != .orderedAscending
      }).last else {
        DispatchQueue.main.async { self.eventViewController!.selectedEvents = [] }
        return
      }
      DispatchQueue.main.async {
        self.eventViewController!.selectedEvents = [event]
        self.eventViewController!.provideDate = true
      }
    }
  }()
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
    case let imagePageViewController as ImagePageViewController:
      coverImagePageViewController = imagePageViewController
    default:
      break
    }
  }
  
}


extension UIMotionEffect {
  class func twoAxesShift(strength: Float) -> UIMotionEffect {
    // internal method that creates motion effect
    func motion(type: UIInterpolatingMotionEffect.EffectType) -> UIInterpolatingMotionEffect {
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
extension UIStoryboard {
  var detailVC : DetailViewController {
    get { 
      return instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    }
  }
}




