//
//  MapViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, ScrollableItem {
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
  
  @IBOutlet weak var fratNameLabel: UILabel!
  private let geoCoder = CLGeocoder()
  
  @IBOutlet weak var favoritesControl: UISegmentedControl!
  
  @IBAction func favoritesControlSelected(_ sender: UISegmentedControl) {
    self.loadAnnotationsIfNecessary(fromAllFrats: sender.selectedSegmentIndex == 0, animated: true, forced: true)
    if let onlyAnnotation = mapView.annotations.first, mapView.annotations.count == 1 {
        mapView.selectAnnotation(onlyAnnotation, animated: true)
    }
    else {
     fratNameLabel.text = "" 
    }
  }

  let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(42.729109), longitude: CLLocationDegrees(-73.677621))
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Do any additional setup after loading the view.
    self.mapView.delegate = self
    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    self.mapView.setCenter(self.center, animated: false)
    self.mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    _ = Campus.shared.percentageCompletionObservable.addObserver(forOwner: self, handler: handleProgress(oldValue:newValue:))
    handleGeocoding(oldValue: nil, newValue: RMGeocoder.observableLocations.addObserver(forOwner: self, handler: handleGeocoding(oldValue:newValue:)))
  
    
  }
  func handleGeocoding(oldValue : [String:CLLocation]?, newValue: [String: CLLocation]) {
    
    let safeOldValue = oldValue ?? [String:CLLocation].init()
    print(newValue.count)
    let changedFrats = Set(newValue.keys).symmetricDifference(Set<String>(safeOldValue.keys))
      for fratName in changedFrats {
        let frat = Campus.shared.fraternitiesDict[fratName]!
          
          let annotation = MKPointAnnotation()
          annotation.coordinate = newValue[fratName]!.coordinate
          annotation.title = frat.name
          annotation.subtitle = frat.getProperty(named: RMDatabaseKey.AddressKey) as? String
          frat.setProperty(named: RMFratPropertyKeys.fratMapAnnotation, to: annotation)
          mapView.addAnnotation(annotation)
        }
  
  }
  func handleProgress(oldValue : Float?, newValue : Float) {
    if newValue == 1 {
      DispatchQueue.main.async {
        //self.loadAnnotationsIfNecessary(fromAllFrats: self.favoritesControl.selectedSegmentIndex == 0, animated: true) 
      }
    }
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
    self.favoritesControl.isEnabled = false
    self.indicator.startAnimating()
    self.view.addSubview(self.overView)
    var loadList = Campus.shared.favoritedFrats
    if fromAllFrats {
      loadList = Set(Campus.shared.fraternitiesDict.keys)
    }
    let geocoder = CLGeocoder()
    var annotations = [MKAnnotation]()
    
    if self.mapView.annotations.isEmpty || annotations.count > self.mapView.annotations.count || forced {
      self.mapView.removeAnnotations(self.mapView.annotations)
      self.mapView.addAnnotations(annotations)
    }
    self.mapView.isScrollEnabled = !self.mapView.annotations.isEmpty
    self.mapView.showAnnotations(self.mapView.annotations, animated: animated)
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
    overView.removeFromSuperview()
    print("removed")
   
    
  }
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let fratName = view.annotation?.title {
      fratNameLabel.text = fratName 
      informationButton.isHidden = false
    }
    else {
      informationButton.isHidden = true
     fratNameLabel.text = "" 
    }
  }
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    fratNameLabel.text = ""
    informationButton.isHidden = true
  }
  
  @IBAction func goToFraternity(_ sender: UIButton) {
    if let fratName = fratNameLabel.text, let superVC = self.parent as? ScrollPageViewController
    {
      superVC.open(fraternityNamed : fratName)
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
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let selectedFrat = mapView.selectedAnnotations.first ,
      let fratName = selectedFrat.title as? String,segue.identifier == "showDetail" {
      SQLHandler.shared.informAction(action: "Fraternity Selected", options: fratName)
      if let selectedFraternity = Campus.shared.fraternitiesDict[fratName] {
        let controller = (segue.destination as! UINavigationController).topViewController
          as! DetailViewController
        
        // Send the detail controller the fraternity we're about to display
        controller.selectedFraternity = selectedFraternity
        //let _ = Campus.shared.getEvents(forFratWithName : fratName)
      }
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
