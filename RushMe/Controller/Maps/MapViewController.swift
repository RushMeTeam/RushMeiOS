//
//  MapViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet var mapView: MKMapView!
//  @IBOutlet var stepper: UIStepper!
  
  private let geoCoder = CLGeocoder()
  @IBOutlet weak var drawerButton: UIBarButtonItem!
  
  @IBOutlet var favoritesControl: UISegmentedControl!
  
  @IBAction func favoritesControlSelected(_ sender: UISegmentedControl) {
    let allFrats = sender.selectedSegmentIndex == 0
    self.loadAnnotations(fromAllFrats: allFrats, animated: true)
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
    if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      drawerButton.target = self.revealViewController()
      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
      // Allow drag to open drawer, tap out to close
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
    //navigationController?.navigationBar.isTranslucent = false
    //navigationController?.navigationBar.backgroundColor = RMColor.AppColor
    //navigationController?.navigationBar.tintColor = RMColor.AppColor
    self.navigationController?.navigationBar.alpha = 0.7
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    // Do any additional setup after loading the view.
    //self.mapView.showsUserLocation = true
    self.mapView.showAnnotations(self.mapView.annotations, animated: false)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    mapView.region.center =  self.center
    self.mapView.setCenter(self.center, animated: false)
    self.mapView.region.span = MKCoordinateSpan.init(latitudeDelta: 0.03, longitudeDelta: 0.03)
    super.viewWillAppear(animated)
    self.loadAnnotations(fromAllFrats: true, animated: false)
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
  }
  
  func loadAnnotations(fromAllFrats: Bool = true, animated : Bool = true) {
    self.favoritesControl.isEnabled = false
    var loadList = Campus.shared.favoritedFrats
    if fromAllFrats {
      loadList = Set(Campus.shared.fraternitiesDict.keys)
    }
    self.mapView.removeAnnotations(mapView.annotations)
    for fratName in loadList {
      let frat = Campus.shared.fraternitiesDict[fratName]!
      if let annotation = frat.getProperty(named: RMFratPropertyKeys.fratMapAnnotation) as? MKAnnotation {
        self.mapView.addAnnotation(annotation)
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
            
            self.mapView.addAnnotation(annotation)
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
    //print("done with " + String(annotations.count))
//    self.mapView.addAnnotations(annotations)
    self.mapView.showAnnotations(self.mapView.annotations, animated: animated)
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
  }
  
  @available(iOS 11.0, *)
  func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
    let cluster = MKClusterAnnotation.init(memberAnnotations: memberAnnotations)
    if memberAnnotations.count == Campus.shared.fraternitiesDict.count {
      cluster.title = "Fraternities at RPI"
    }
    else {
      var title = ""
      var numFrats = 0
      let maxFrats = 3
      for annotation in memberAnnotations {
        title += annotation.title!!.greekLetters
        numFrats += 1
        if numFrats < maxFrats {
          title += ", "
        }
        else {
          break
        }
        
      }
    }
    return cluster
  }
  func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
    self.favoritesControl.isEnabled = false
  }
  func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    self.favoritesControl.isEnabled = Campus.shared.hasFavorites
    
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
