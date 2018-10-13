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
class DetailViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, UIViewControllerPreviewingDelegate {
  
  
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
  var favoritesButton = UIBarButtonItem(image: Frontend.images.unfilledHeart, style: .plain, target: self, action: #selector(favoritesButtonHit))
  //@IBOutlet weak var favoritesButton : UIBarButtonItem!
  @IBOutlet weak var blockTextView: UITextView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var openMapButton: UIButton!
  @IBOutlet var toMakeClear: [UIView]!
  var newImageViewController : ImageViewController? {
    get {
     return UIStoryboard.main.instantiateViewController(withIdentifier: "imageVC") as? ImageViewController 
    }
  }
//  private var _coverImagePageViewController  : ImagePageViewController? 
//  var coverImagePageViewController  : ImagePageViewController! {
//    get {
//      if let _ = _coverImagePageViewController  {
//        return _coverImagePageViewController  
//      }
//      for viewController in childViewControllers where (viewController as? ImagePageViewController == nil) ? false : true {
//        _coverImagePageViewController  = viewController as! ImagePageViewController
//        return viewController as! ImagePageViewController
//      }
//      return nil
//    }
//  }
 
  private var coverImagePageViewController : ImagePageViewController!
 
  
  
  var openInMapsAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Open in Maps", style: .default, handler: { (_) in
        MKMapItem.openMaps(with: [self.mapItem!], launchOptions: nil)
      }) 
    }
  }
  var cancelAction : UIAlertAction {
    get {
      return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
  }
  // MARK: Member Variables
  @IBOutlet weak var eventView: UIView!
  private var _eventViewController : EventTableViewController? 
  var eventViewController : EventTableViewController! {
    get {
      _eventViewController = _eventViewController ?? children.first(where: { (child) -> Bool in
        return child is EventTableViewController
      }) as? EventTableViewController
      return _eventViewController
    }
  }
  var mapItem : MKMapItem?
  var selectedFraternity: Fraternity? = nil {
    didSet {
      if let frat = selectedFraternity {
        eventViewController?.selectedEvents = Array(frat.events)
        title = frat.name.greekLetters
      }
    }
  }
  
  
  // MARK: IBActions
  @objc func favoritesButtonHit(_ sender: UIBarButtonItem) {
    if let fratName = selectedFraternity?.name {
      if Campus.shared.favoritedFrats.contains(fratName) {
        _ = Campus.shared.removeFavorite(named: fratName)
        sender.image = Frontend.images.unfilledHeart
        self.profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
      }
      else {
        _ = Campus.shared.addFavorite(named: fratName)
        sender.image = Frontend.images.filledHeart
        self.profileImageView.layer.borderColor = Frontend.colors.AppColor.withAlphaComponent(0.7).cgColor
      }
    }
  }
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    if profileImageView.point(inside: location, with: nil), let imageVC = newImageViewController,
      let image = profileImageView.image {
      imageVC.image = image
     return imageVC
    }
    return nil
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    (viewControllerToCommit as? ImageViewController)?.addVisualEffectView()
    present(viewControllerToCommit, animated: true) { 
    }
  }
  
  override var previewActionItems: [UIPreviewActionItem] {
    get {
     return [
      UIPreviewAction(title: Campus.shared.favoritedFrats.contains(self.selectedFraternity?.name ?? "") ? "Unfavorite" : "Favorite", style: .default) { (action, targetVC) in
//        self.favoritesButtonHit()
      }]
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
    }, completion: { _ in })
    if let imageVC = newImageViewController {
      if profileImageView.frame.contains(sender.location(in: view)),
        let image = profileImageView.image {
        imageVC.image = image
      }
      else if let image = coverImagePageViewController.currentPageImage {
        imageVC.image = image
      }
      if imageVC.image.size != .zero && imageVC.image != Frontend.images.noImage  {
        imageVC.addVisualEffectView()
        present(imageVC, animated: true, completion: nil)
      }
    }
  }
  @IBAction func coverImagePinched(_ sender: UIPinchGestureRecognizer) {
    if sender.state == .began || sender.state == .changed {
      guard let senderView = sender.view as? UIImageView, 
        senderView.image != Frontend.images.noImage else { return }
      self.scrollView.isScrollEnabled = false
      let currScale = senderView.frame.size.width/senderView.bounds.size.width
      var newScale = currScale*sender.scale
      var maxScale : CGFloat = 2
      if (sender.view == profileImageView) {
        maxScale = (view.bounds.width*0.9)/senderView.bounds.width
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
        if let view = sender.view {
          view.transform = CGAffineTransform.identity
          view.layer.shadowOpacity = 0
          view.clipsToBounds = true
        }
        self.setViews(toAlpha: 1)
      }, completion: { _ in
        
        
      })
    }
  }  
  @IBAction func openInMaps(_ sender: UIButton) {
    guard let _ = mapItem, let frat = selectedFraternity else {
      return  
    }
    let addressAlert = UIAlertController.init(title: frat.name, message: frat.address, preferredStyle: .actionSheet)
    addressAlert.view.tintColor = Frontend.colors.AppColor
    addressAlert.addAction(openInMapsAction)
    addressAlert.addAction(cancelAction)
    self.present(addressAlert, animated: true, completion: nil)
    
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
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
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
    mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
    mapView.layer.cornerRadius = Frontend.cornerRadius
    mapView.layer.masksToBounds = true
    view.backgroundColor = .clear
    parent?.view.backgroundColor = Frontend.colors.AppColor
  }()
  // MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    registerForPreviewing(with: self, sourceView: profileImageView)
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.profileImageView.transform = CGAffineTransform.identity
    self.profileImageView.alpha = 1
    self.coverImageView.transform = CGAffineTransform.identity
    self.coverImageView.alpha = 1
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
      if let coverImageURLs = frat.coverImagePaths {
        imageVC.imageNames.append(contentsOf: coverImageURLs)
      }
    }
    profileImageView.setImageByURL(fromSource: frat.profileImagePath)
    titleLabel.text = frat.name
    underProfileLabel.text = frat.chapter + " Chapter"
    if let memberCount = frat.memberCount {
      self.memberCountLabel.text = String(describing: memberCount) + " Members"
    }
    
    if Campus.shared.favoritedFrats.contains(frat.name) {
      self.favoritesButton.image = Frontend.images.filledHeart
      self.profileImageView.layer.borderColor = Frontend.colors.AppColor.withAlphaComponent(0.7).cgColor
    }
    else {
      self.favoritesButton.image = Frontend.images.unfilledHeart
      self.profileImageView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    }
    favoritesButton.title = frat.name
    blockTextView.text = frat.description
    blockTextView.sizeToFit()
    scrollView.isScrollEnabled = true
    
    if let location = frat.coordinates {
      let annotation = MKPointAnnotation()
      annotation.coordinate = location.coordinate
      annotation.title = frat.name
      annotation.subtitle = frat.address
      mapView.addAnnotation(annotation)
      mapView.setCenter(annotation.coordinate, animated: false)
      mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
      mapItem!.name = frat.name
    } else {
      self.mapView.isScrollEnabled = false
      self.mapView.setCenter(RushMe.campus.coordinates, animated: false)
    }
    // Do any additional setup after loading the view, typically from a nib.
    DispatchQueue.global(qos: .utility).async {
      if let event = Campus.shared.getEvents(forFratWithName: frat.name).filter({ (value) -> Bool in
        return User.preferences.considerPastEvents || value.startDate.compare(.today) != .orderedAscending
      }).last {
        DispatchQueue.main.async {
          self.eventViewController!.selectedEvents = [event]
          self.eventViewController!.provideDate = true
        }
      } else {
        DispatchQueue.main.async {
          self.eventViewController!.selectedEvents = []
        }
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
      return self.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    }
  }
}




