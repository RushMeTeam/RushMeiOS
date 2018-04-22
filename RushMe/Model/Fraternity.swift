//
//  Fraternity.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit
class Fraternity : NSObject {
  // The name of the fraternity
  // e.g. "Lambda Lambda Chi"
  let name : String
  // The chapter of the fraternity (if no chapter, then school)
  // e.g. "Rho Chapter" or "RPI Chapter"
  let chapter : String
  // The previewImage is the image seen when the user scrolls through a list of fraternities
  // e.g. a picture of the house, possibly the profile image
  var previewImage : UIImage?
  // All the Fraternity's associated rush events are stored in events
  var events = [Date : FratEvent]()
  // All data in the Fraternity object is stored again in properties
  private var properties : Dictionary<String, Any>
  init(name : String,
       chapter : String,
       previewImage: UIImage?,
       properties : Dictionary<String, Any>) {
    
    self.name = name
    self.chapter = chapter
    self.properties = properties
    if let previewImg = previewImage {
      self.previewImage = previewImg
    }
    else {
      if let profImage = self.properties["profileImage"] as? UIImage {
        self.previewImage = profImage
      }
      else {
        self.previewImage = RMImage.NoImage
      }
    }
    if self.properties["profileImage"] != nil {
      self.properties["profileImage"] = previewImage
    }
  }
  
  func getProperty(named : String) -> Any? {
    if (named == "name"){ return self.name }
    if (named == "chapter"){ return self.chapter }
    if (named == "previewImage"){ return self.previewImage }
    return properties[named]
  }
  func setProperty(named : String, to : Any) {
    properties[named] = to
  }
  func add(eventDescribedBy dict : Dictionary<String, Any>) -> FratEvent? {
    //house, event_name, start_time, end_time, event_date, location
    // start_time, end_time, location possibly nil
    let houseName = dict["house"] as! String
    if (self.name != houseName){
      return nil
    }
    let eventName = dict["event_name"] as! String
    let eventDate = dict["event_date"] as! String
    let location = dict["location"] as? String
    let startTime = dict["start_time"] as? String
    let endTime = dict["end_time"] as? String
    if let event = FratEvent(withName: eventName,
                             onDate: eventDate,
                             ownedByFraternity: self,
                             startingAt: startTime,
                             endingAt: endTime,
                             atLocation: location) {
      self.events[event.startDate] = event
      return event
    }
    return nil
  }
  
}
// A not-so-genius way to create greek representations of frat names
extension String {
  var greekLetters : String {
    get {
      var result = self.replacingOccurrences(of: "Alpha", with: "Α")// -> A
      result = result.replacingOccurrences(of: "Beta", with: "Β")         // -> Β
      result = result.replacingOccurrences(of: "Gamma", with: "Γ")        // -> Γ
      result = result.replacingOccurrences(of: "Delta", with: "Δ")        // -> Δ
      result = result.replacingOccurrences(of: "Epsilon", with: "Ε")      // -> Ε
      result = result.replacingOccurrences(of: "Zeta", with: "Ζ")         // -> Ζ
      result = result.replacingOccurrences(of: "Eta", with: "Η")          // -> H
      result = result.replacingOccurrences(of: "Theta", with: "Θ")        // -> Θ
      result = result.replacingOccurrences(of: "Iota", with: "Ι")         // -> Ι
      result = result.replacingOccurrences(of: "Kappa", with: "Κ")        // -> Κ
      result = result.replacingOccurrences(of: "Lambda", with: "Λ")       // -> Λ
      result = result.replacingOccurrences(of: "Mu", with: "Μ")           // -> Μ
      result = result.replacingOccurrences(of: "Nu", with: "Ν")           // -> Ν
      result = result.replacingOccurrences(of: "Xi", with: "Ξ")           // -> Ξ
      result = result.replacingOccurrences(of: "Omicron", with: "Ο")      // -> Ο
      result = result.replacingOccurrences(of: "Pi", with: "Π")           // -> Π
      result = result.replacingOccurrences(of: "Rho", with: "Ρ")          // -> Ρ
      result = result.replacingOccurrences(of: "Sigma", with: "Σ")        // -> Σ
      result = result.replacingOccurrences(of: "Tau", with: "Τ")          // -> Τ
      result = result.replacingOccurrences(of: "Upsilon", with: "Υ")      // -> Y
      result = result.replacingOccurrences(of: "Phi", with: "Φ")          // -> Φ
      result = result.replacingOccurrences(of: "Chi", with: "Χ")          // -> Χ
      result = result.replacingOccurrences(of: "Psi", with: "Ψ")          // -> Ψ
      result = result.replacingOccurrences(of: "Omega", with: "Ω")        // -> Ω
      return result
    }
}

}

