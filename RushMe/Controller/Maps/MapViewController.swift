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
    DispatchQueue.main.async {
      self.loadViewIfNeeded()
      self.loadAnnotationsIfNecessary(fromAllFrats: self.favoritesControl.selectedSegmentIndex == 0, animated: false) 
      self.viewWillAppear(false)
    }
  }
  @IBOutlet weak var mapView: MKMapView!
  //  @IBOutlet var stepper: UIStepper!
  @IBOutlet weak var informationButton: UIButton!
  
  @IBOutlet weak var fratNameLabel: UILabel!
  private let geoCoder = CLGeocoder()
  
  @IBOutlet weak var favoritesControl: UISegmentedControl!
  
  @IBAction func favoritesControlSelected(_ sender: UISegmentedControl) {
    self.loadAnnotationsIfNecessary(fromAllFrats: sender.selectedSegmentIndex == 0, animated: true)
    if let onlyAnnotation = mapView.annotations.first, mapView.annotations.count == 1 {
        mapView.selectAnnotation(onlyAnnotation, animated: true)
    }
    else {
     fratNameLabel.text = "" 
    }
  }
  //
  //  @IBAction func stepperSelected(_ sender: UIStepper) {
  //    // Iterate through all annotations
  //    self.mapView.showAnnotations([self.mapView.annotations[Int(sender.value)%self.mapView.annotations.count]], animated: true)
  //  }
  let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(42.729109), longitude: CLLocationDegrees(-73.677621))
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  
//    if (self.revealViewController() != nil) {
//      // Allow drawer button to toggle the lefthand drawer menu
//      drawerButton.target = self.revealViewController()
//      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
//      // Allow drag to open drawer, tap out to close
//      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
//    }
    //navigationController?.navigationBar.isTranslucent = false
    //navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    //navigationController?.navigationBar.tintColor = RMColor.AppColor
//    self.navigationController?.navigationBar.alpha = 0.7
    //self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Do any additional setup after loading the view.
    //self.mapView.showsUserLocation = true
    self.mapView.delegate = self
    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    self.mapView.setCenter(self.center, animated: false)
    self.mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    //    mapView.region.center =  self.center
    
    super.viewWillAppear(animated)
    
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
  }
  // TODO : Fix favorites annotations BUG
  func loadAnnotationsIfNecessary(fromAllFrats: Bool = true, animated : Bool = true) {
    self.favoritesControl.isEnabled = false
    var loadList = Campus.shared.favoritedFrats
    if fromAllFrats {
      loadList = Set(Campus.shared.fraternitiesDict.keys)
    }
    var annotations = [MKAnnotation]()
    for fratName in loadList {
      let frat = Campus.shared.fraternitiesDict[fratName]!
      if let annotation = frat.getProperty(named: RMFratPropertyKeys.fratMapAnnotation) as? MKAnnotation {
        annotations.append(annotation)
      }
      
      else if let address = frat.getProperty(named: RMDatabaseKey.AddressKey) as? String {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {
          (placemarks, error) in
          if let location = placemarks?.first?.location {
            let annotation = MKPointAnnotation.init()
            annotation.coordinate = location.coordinate
            annotation.title = frat.name
            annotation.subtitle = address
            
            annotations.append(annotation)
            frat.setProperty(named: RMFratPropertyKeys.fratMapAnnotation, to: annotation)
          }
          else if let _ = error {
            print(error!.localizedDescription)
          }
          else {
            // handle no location found
            print("No location found for " + frat.name + " with address " + address)
          }
        })
      }
      
      
    }
    if mapView.annotations.isEmpty || annotations.count > mapView.annotations.count {
      self.mapView.removeAnnotations(mapView.annotations)
      self.mapView.addAnnotations(annotations)
    }
    self.mapView.isScrollEnabled = !mapView.annotations.isEmpty
    //self.mapView.showAnnotations(self.mapView.annotations, animated: animated)
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
  }
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let fratName = view.annotation?.title {
      fratNameLabel.text = fratName 
      //informationButton.isHidden = false
    }
    else {
     fratNameLabel.text = "" 
    }
  }
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    fratNameLabel.text = ""
    informationButton.isHidden = true
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
