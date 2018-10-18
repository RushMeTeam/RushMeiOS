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
class Fraternity : Hashable {
  static func == (lhs: Fraternity, rhs: Fraternity) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
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
  let profileImagePath : RMURL!
  // The path to a possible calendar image
  let calendarImagePath : RMURL!
  // All other images
  let coverImagePaths : [RMURL]
  // The physical address of the fraternity
  let address : String?
  let coordinates : CLLocationCoordinate2D? 
  let memberCount : Int!
  init(name : String, description : String, 
       chapter : String, 
       memberCount : Int?, 
       profileImagePath : RMURL?, 
       calendarImagePath : RMURL?, 
       coverImagePaths : [RMURL] = [], 
       address : String?, 
       coordinates : CLLocationCoordinate2D?) {
    self.name = name
    self.description = description
    self.chapter = chapter
    self.profileImagePath = profileImagePath
    self.coverImagePaths = coverImagePaths
    self.calendarImagePath = calendarImagePath
    self.address = address
    self.coordinates = coordinates
    self.memberCount = memberCount
  }
  
  
  var hashValue : Int {
    get {
      return name.djb2hash ^ chapter.djb2hash
    }
  }
  // The number of active members
  
  // All data in the Fraternity object is stored again in properties
  
  
  
  
  class Event : Hashable {
    static func == (lhs: Fraternity.Event, rhs: Fraternity.Event) -> Bool {
      return lhs.frat == rhs.frat && lhs.startDate == rhs.startDate && lhs.name == rhs.name
    }
    
    let calendar = Calendar.current
    let startDate : Date
    let endDate : Date
    let name : String
    let location : String?
    let frat : Fraternity
    
    // TODO: Fix RushMe.dateTimeFormatter to work for 24hr time
    init?(withName : String,
          onDate : String,
          ownedByFraternity : Fraternity,
          startingAt : String? = nil,
          endingAt : String? = nil,
          atLocation : String? = nil) {
      
      self.name = withName
      self.frat = ownedByFraternity
      self.location = atLocation
      
      
      self.startDate = ((startingAt == nil) ? Format.dates.dateFormatter.date(from: onDate) : Format.dates.dateTimeFormatter.date(from: onDate + " " + startingAt!))!
      self.endDate = ((endingAt == nil) ? startDate : Format.dates.dateTimeFormatter.date(from: onDate + " " + endingAt!))!
    }
    var hashValue : Int {
      get {
       return startDate.hashValue ^ endDate.hashValue ^ frat.hashValue ^ name.djb2hash
      }
    }
    var dayKey : String {
      return DateFormatter.localizedString(from: self.startDate, dateStyle: .medium, timeStyle: .none)
    }
    static func <(lhs : Fraternity.Event, rhs : Fraternity.Event) -> Bool {
      return lhs.startDate < rhs.startDate 
    }
    
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
// Make a date, such as Sunday, November 22nd, 12:00PM return its time, as a string, i.e. "12:00PM"
// An extension to Date that empowers the FratEvent class.
extension Date {
  func formatToHour() -> String {
    let time = DateFormatter.localizedString(from: self,
                                             dateStyle: DateFormatter.Style.none,
                                             timeStyle: DateFormatter.Style.full)
    let AmPm = String(time.split(separator: " ")[1])
    let split = time.split(separator: ":")
    let hour = String(split[0])
    let min = String(split[1])
    return hour + ":" +  min + " " + AmPm
    
  }
  
}


extension Fraternity {
  var isFavorite : Bool {
    return User.session.favoriteFrats.contains(name)
  }
  
}
extension String {
  var djb2hash: Int {
    let unicodeScalars = self.unicodeScalars.map { $0.value }
    return unicodeScalars.reduce(5381) {
      ($0 << 5) &+ $0 &+ Int($1)
    }
  }
  
  var sdbmhash: Int {
    let unicodeScalars = self.unicodeScalars.map { $0.value }
    return unicodeScalars.reduce(0) {
      Int($1) &+ ($0 << 6) &+ ($0 << 16) - $0
    }
  }
}
