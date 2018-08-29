//
//  Fraternity.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class Fraternity {
  // The name of the fraternity
  // e.g. "Lambda Lambda Chi"
  let name : String
  // The fraternity's description
  let description : String
  // The chapter of the fraternity (if no chapter, then school)
  // e.g. "Rho Chapter" or "RPI Chapter"
  let chapter : String
  // The previewImage is the image seen when the user scrolls through a list of fraternities
  // e.g. a picture of the house, possibly the profile image
  let profileImagePath : RMURL
  // The path to a possible calendar image
  let calendarImagePath : RMURL?
  // All other images
  let coverImagePaths : [RMURL]?
  // The physical address of the fraternity
  let address : String?
  var coordinates : CLLocation? {
   return RMGeocoder.locations[name] 
  }
  // All the Fraternity's associated rush events are stored in events
  var events : [Date : FratEvent]!
  // The number of active members
  var memberCount : Int?
  // All data in the Fraternity object is stored again in properties
  private var dictionaryRepresentation : Dictionary<String, Any>
  init?(withDictionary dictionary : [String : Any]) {
    if let name = dictionary[RushMe.keys.frat.name] as? String,
      let statement = dictionary[RushMe.keys.frat.description] as? String,
      let chapter = dictionary[RushMe.keys.frat.chapter] as? String,
      let profileImagePathRaw = dictionary[RushMe.keys.frat.profileImage] as? String,
      let profileImagePath = RMURL(fromString: profileImagePathRaw) {
      self.name = name
      self.description = statement
      self.chapter = chapter
      self.profileImagePath = profileImagePath
      if let memberCountRaw = dictionary[RushMe.keys.frat.memberCount] as? String,
        let memberCount = Int(memberCountRaw){
        self.memberCount = abs(memberCount)
      }
      if let calendarImagePathRaw = dictionary[RushMe.keys.frat.calendarImage] as? String {
          self.calendarImagePath = RMURL(fromString: calendarImagePathRaw)
      }
      else {
            self.calendarImagePath = nil
      }
      self.address = dictionary[RushMe.keys.frat.address] as? String
       
      self.dictionaryRepresentation = dictionary
      // TODO: Allow for multiple images
      self.coverImagePaths = nil
    }
    else {
     return nil 
    }
  }
  

  
  func getUnmarkedProperty(named : String) -> Any? {
    if (named == "name"){ return self.name }
    if (named == "chapter"){ return self.chapter }
    return dictionaryRepresentation[named]
  }
  func add(eventDescribedBy dict : Dictionary<String, Any>) -> FratEvent? {
    //house, event_name, start_time, end_time, event_date, location
    // start_time, end_time, location possibly nil
    if events == nil {
      events = [:] 
    }
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
      if (result != self) {
        result = result.replacingOccurrences(of: " ", with: "")
      }
      return result
    }
}

}

