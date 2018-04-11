//
//  RMGeocoder.swift
//  RushMe
//
//  Created by Adam Kuniholm on 4/10/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import MapKit

class RMGeocoder {
  private static let geocoder = CLGeocoder()
  private(set) static var observableLocations = Observable(locations)
  private(set) static var locations = Dictionary<String, CLLocation>() 
  static func geocode(selectedFraternities loadList : [String]) {
    if let fratName = loadList.last, let frat = Campus.shared.fraternitiesDict[fratName], let address = frat.getProperty(named: RMDatabaseKey.AddressKey) as? String {
      geocoder.geocodeAddressString(address, completionHandler: {
        (placemarks, error) in
        
        if let location = placemarks?.first?.location {
          locations[fratName] = location
          observableLocations.value[fratName] = location
        }
        else if let _ = error {
          print(error!.localizedDescription)
        }
        else {
          // handle no location found
          print("No location found for " + frat.name + " with address " + address)
        }
        geocode(selectedFraternities: Array(loadList[0..<loadList.count-1]))
      })
    }
  }
}
