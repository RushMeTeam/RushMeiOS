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
  @IBOutlet weak var navigationBarExtensionView: UIView!
  
  func updateData() {
    DispatchQueue.main.async {
      self.loadViewIfNeeded()
      self.loadAnnotationsIfNecessary(fromAllFrats: self.favoritesControl.selectedSegmentIndex == 0, animated: false) 
      self.favoritesControl.isEnabled = Campus.shared.hasFavorites
      if !Campus.shared.hasFavorites {
        self.favoritesControl.selectedSegmentIndex = 0
      }
      self.viewWillAppear(false)
    }
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
        return annotation.title == nil || Campus.shared.fraternitiesByName[annotation.title!!]?.isFavorite ?? false
      }
      mapView.removeAnnotations(notFavorited)
    } else {
      mapView.addAnnotations(fratAnnotations)
    }
    mapView.showAnnotations(mapView.annotations, animated: true)
  }
  
  let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(42.729109), longitude: CLLocationDegrees(-73.677621))
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedString.Key.foregroundColor: Frontend.colors.NavigationItemsColor]
    self.favoritesControl.tintColor = Frontend.colors.NavigationBarTintColor
    self.fratNameButton.tintColor = Frontend.colors.NavigationItemsColor
    self.informationButton.tintColor = Frontend.colors.NavigationItemsColor
    self.navigationBarExtensionView.backgroundColor = Frontend.colors.NavigationBarColor
    
    self.mapView.delegate = self
    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    self.mapView.setCenter(self.center, animated: false)
    self.mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    self.loadAnnotationsIfNecessary(fromAllFrats: !viewingFavorites, animated: false) 
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

    self.favoritesControl.isEnabled = Campus.shared.hasFavorites || favoritesControl.selectedSegmentIndex == 1
    
    for frat in Campus.shared.fraternitiesByName.values where frat.coordinates != nil {
      let annotation = MKPointAnnotation()
      annotation.coordinate = frat.coordinates!
      annotation.title = frat.name
      annotation.subtitle = frat.address
      mapView.addAnnotation(annotation)
      mapView.isScrollEnabled = !self.mapView.annotations.isEmpty
    }
//    for frat in Campus.shared.fraternitiesByName.values where frat.coordinates == nil {
//     print(frat.name) 
//    }
    self.mapView.showAnnotations(self.mapView.annotations, animated: animated)
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
//    self.performSegue(withIdentifier: "showDetail", sender: mapView.selectedAnnotations.first?.title as Any)
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail", let fratName = sender as? String, let selectedFraternity = Campus.shared.fraternitiesByName[fratName] {
      Backend.log(action: .Selected(fraternity: selectedFraternity))
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
    let button = UIBarButtonItem(image: frat.isFavorite ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")  , style: .plain, target: self, action: #selector(MasterViewController.toggleFavorite(sender:)))
    button.title = frat.name
    return button
  }
  @objc func toggleFavorite(sender : UIBarButtonItem) {
    if let fratName = sender.title, let frat = Campus.shared.fraternitiesByName[fratName] {
      sender.image = Campus.shared.toggleFavorite(frat: frat) ? #imageLiteral(resourceName: "FavoritesIcon") : #imageLiteral(resourceName: "FavoritesUnfilled")
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
