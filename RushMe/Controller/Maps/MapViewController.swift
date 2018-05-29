//
//  MapViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, 
                         MKMapViewDelegate, 
                         ScrollableItem {
  
  
  func updateData() {
      self.loadViewIfNeeded()
      self.loadAnnotationsIfNecessary(fromAllFrats: self.favoritesControl.selectedSegmentIndex == 0, animated: false) 
      self.favoritesControl.isEnabled = Campus.shared.hasFavorites
      if !Campus.shared.hasFavorites {
        self.favoritesControl.selectedSegmentIndex = 0
      }
      self.viewWillAppear(false)
  }
  lazy var indicator : UIActivityIndicatorView = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 128, height: 128))
  lazy var overView : UIVisualEffectView = {
    let newView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    newView.frame = view.bounds
    indicator.center = newView.center
    newView.contentView.addSubview(indicator)
    indicator.startAnimating()
    return newView
  }()

  @IBOutlet weak var mapView: MKMapView!
  //  @IBOutlet var stepper: UIStepper!
  @IBOutlet weak var informationButton: UIButton!
  
  @IBOutlet weak var fratNameButton: UIButton!
  
  @IBOutlet weak var favoritesControl: UISegmentedControl!
  
  var viewingFavorites : Bool {
    get {
     return favoritesControl.selectedSegmentIndex == 1 
    }
  }
  private(set) var fratAnnotations = [MKAnnotation]()
  
  @IBAction func favoritesControlSelected(_ sender: UISegmentedControl) {
    self.loadAnnotationsIfNecessary(fromAllFrats: sender.selectedSegmentIndex == 0, animated: true, forced: true)
    fratNameButton.setTitle(nil, for: .normal)
    if viewingFavorites {
      let notFavorited = mapView.annotations.filter { (annotation) -> Bool in
        return annotation.title == nil || !Campus.shared.favoritedFrats.contains(annotation.title!!)
      }
      mapView.removeAnnotations(notFavorited)
    } else {
      mapView.addAnnotations(fratAnnotations)
    }
    mapView.showAnnotations(mapView.annotations, animated: true)
    
//    if let onlyAnnotation = mapView.annotations.first, mapView.annotations.count == 1 {
//        mapView.selectAnnotation(onlyAnnotation, animated: true)
//    }
//    else {
//     fratNameLabel.text = "" 
//    }
  }

  let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(42.729109), longitude: CLLocationDegrees(-73.677621))
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Do any additional setup after loading the view.
    self.fratNameButton.title
    self.mapView.layer.cornerRadius = 5
    self.mapView.layer.masksToBounds = true
    self.mapView.delegate = self
    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    self.mapView.setCenter(self.center, animated: false)
    self.mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    RMGeocoder.observableLocations.addObserver(forOwner: self, handler: handleGeocoding(oldValue:newValue:))
  }
  func handleGeocoding(oldValue : [String:CLLocation]?, newValue: [String: CLLocation]) {
    let safeOldValue = oldValue ?? [String:CLLocation].init()
    let changedFrats = Set(newValue.keys).symmetricDifference(Set<String>(safeOldValue.keys))
    for fratName in changedFrats {
      let frat = Campus.shared.fraternitiesDict[fratName]!
      let annotation = MKPointAnnotation()
      annotation.coordinate = newValue[fratName]!.coordinate
      annotation.title = frat.name
      annotation.subtitle = frat.getProperty(named: RushMe.keys.frat.address) as? String
      mapView.addAnnotation(annotation)
      mapView.isScrollEnabled = !self.mapView.annotations.isEmpty
      
    }
    fratAnnotations = mapView.annotations
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    favoritesControl.isEnabled = Campus.shared.hasFavorites
  }
  // TODO : Fix favorites annotations BUG
  func loadAnnotationsIfNecessary(fromAllFrats: Bool = true, animated : Bool = true, forced : Bool = false) {
    self.indicator.startAnimating()
   
    self.mapView.isScrollEnabled = !self.mapView.annotations.isEmpty
    self.mapView.showAnnotations(self.mapView.annotations, animated: animated)
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites || favoritesControl.selectedSegmentIndex == 1
  }
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let fratName = view.annotation?.title {
      fratNameButton.setTitle(fratName?.greekLetters, for: .normal) 
      informationButton.isHidden = false
    }
    else {
      informationButton.isHidden = true
     fratNameButton.setTitle(nil, for: .normal)
    }
  }
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    fratNameButton.setTitle(nil, for: .normal)
    informationButton.isHidden = true
  }
  
  @IBAction func goToFraternity(_ sender: Any) {
    self.performSegue(withIdentifier: "showDetail", sender: mapView.selectedAnnotations.first?.title as Any)
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail", let fratName = sender as? String, let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
      SQLHandler.inform(action: .FraternitySelected, options: fratName)
      let controller = segue.destination as! UIPageViewController
      controller.title = fratName.greekLetters
      controller.navigationItem.setRightBarButton(barButtonItem(for: selectedFraternity), animated: false)
      controller.title = fratName.greekLetters
      controller.view.backgroundColor = .white
      let dVC = UIStoryboard.main.detailVC
      dVC.selectedFraternity = selectedFraternity
      controller.setViewControllers([dVC], direction: .forward, animated: false)
    }
  }
  func barButtonItem(for frat : Fraternity) -> UIBarButtonItem {
    let button = UIBarButtonItem(image: Campus.shared.favoritedFrats.contains(frat.name) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")  , style: .plain, target: self, action: #selector(MasterViewController.toggleFavorite(sender:)))
    button.title = frat.name
    return button
  }
  @objc func toggleFavorite(sender : UIBarButtonItem) {
    if let fratName = sender.title {
      sender.image = Campus.shared.toggleFavorite(named: fratName) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")
    }
  }
  
  
//  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//    let identifier = "Fraternity"
//    //    if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//    //      annotationView.annotation = annotation
//    //      return annotationView 
//    //    }
//    //    else {
//    //      let annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier) 
//    //      annotationView.isEnabled = true
//    //      annotationView.canShowCallout = true
//    //      
//    //      let button = UIButton(type: .detailDisclosure)
//    //      annotationView.rightCalloutAccessoryView = button
//    //      return annotationView
//    //    }
//    return nil
//  }
  
  
  //  @available(iOS 11.0, *)
  //  func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
  //    let cluster = MKClusterAnnotation.init(memberAnnotations: memberAnnotations)
  //    if memberAnnotations.count == Campus.shared.fraternitiesDict.count {
  //      cluster.title = "Fraternities at RPI"
  //    }
  //    else {
  //      var title = ""
  //      var numFrats = 0
  //      let maxFrats = 3
  //      for annotation in memberAnnotations {
  //        title += annotation.title!!.greekLetters
  //        numFrats += 1
  //        if numFrats < maxFrats {
  //          title += ", "
  //        }
  //        else {
  //          break
  //        }
  //        
  //      }
  //    }
  //    return cluster
  //  }
  @IBAction func centerMap(_ sender: UIBarButtonItem) {
    centerMap(animated : true)
  }
  func centerMap(animated : Bool) {
    self.mapView.showAnnotations(self.mapView.annotations, animated: animated) 
  }
  
//  func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//    self.favoritesControl.isEnabled = false
//  }
//  func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
//    
//  }
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    super.prepare(for: segue, sender: sender)
//    if let selectedFrat = mapView.selectedAnnotations.first ,
//      let fratName = selectedFrat.title as? String,segue.identifier == "showDetail" {
//      SQLHandler.shared.informAction(action: "Fraternity Selected", options: fratName)
//      if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
//        let controller = (segue.destination as! UINavigationController).topViewController
//          as! DetailViewController
//        controller.selectedFraternity = selectedFraternity
//      }
//    }
//  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
