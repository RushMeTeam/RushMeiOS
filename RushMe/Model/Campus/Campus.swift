//
//  Campus.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
// Create a shared instance of the Campus class which
// cannot be deinstantiated or instantiated, except by
// the App itself


// Describe three quality metrics
enum Quality : Int {
  case High = 3
  case Medium = 2
  case Low = 1
}
/*
 A centralized data repository to be used by all components of the
 app, in order to decrease improper and computation-heavy passing
 of data. In addition, centralization provides ability to easily
 and safely save the data, for example if a user wants their
 favorites to be available even after they have exited the app
 permenantly.
 
 Inheritance from NSObject provides future capabilities, namely
 saving.
 */


class Campus {
  // MARK: Member Variables
  // The user's favorite fraternities
  
  // Returns whether favorite was added, false if it was already a favorite
  func favorite(fratNamed newFavorite : String) -> Bool {
    if User.session.favoriteFrats.insert(newFavorite).inserted {
      Backend.log(action: .FraternityFavorited, options: newFavorite)
      return true
    }
    return false
  }
  // Returns whether favorite was removed
  func unfavorite(fratNamed oldFavorite : String) -> Bool{
    if let _ = User.session.favoriteFrats.remove(oldFavorite) {
      Backend.log(action: .FraternityUnfavorited, options: oldFavorite)
      return true
    }
    return false
  }
  
  var hasFavorites : Bool {
    return !User.session.favoriteFrats.isEmpty
  }
  // The name of every fraternity on this Campus
  @objc var fraternityNames : Set<String> {
    get {
      return Set<String>(fraternitiesByName.keys)
    }
  }
  
  
  // Refer to each fraternity by its name, in no order
  private(set) var fraternitiesByName = [String : Fraternity]()
  private(set) var fraternitiesByKey = [String : Fraternity]()
  
  // The default quality at which an image should be downloaded
  static var downloadedImageQuality : Quality = .Medium
  // MARK: Shared Instance (singleton)
  static let shared : Campus = Campus()
  
  var isLoading : Bool {
    get {
      return percentageCompletion != 0 && percentageCompletion != 1
    }
  }
  private(set) var percentageCompletionObservable = Observable<Float>(0)
  private(set) var percentageCompletion : Float = 0 {
    willSet {
      percentageCompletionObservable.value = newValue
    }
  }
  var lastDictArray : [Dictionary<String,Any>]? = nil 
  
  func pullFromBackend() {
    if !isLoading {
      self.percentageCompletion = 0.2
      DispatchQueue.global(qos: .userInitiated).async {
        
        var dictArray = [Dictionary<String, Any>]()
        var eventArray = [Dictionary<String, Any>]()
        
        if let fratArray = try? Backend.selectAll(fromTable: Database.keys.database.fraternities),
          self.lastDictArray == nil || fratArray.count > self.lastDictArray!.count, 
          let eventArr = try? Backend.selectAll(fromTable: Database.keys.database.events) {
          dictArray = fratArray
          eventArray = eventArr
          self.lastDictArray = dictArray
        }
        dictArray.forEach({ (dict) in
          if let frat = Fraternity(withDictionary: dict) {
            try? Campus.shared.add(fraternity: frat) 
          }
        })
        // TODO: Input events into rushcalendar
        eventArray.forEach({ (dict) in
          _ = RushCalendar.shared.add(eventDescribedBy: dict)
        })
        self.percentageCompletion = 1
      } 
    }
    else {
      print("(Tried to refresh when loading)") 
    }
  }
  
  enum CampusError : Error {
    case registrationError(fraternity: Fraternity)
    case duplicateRegistration(fraternity : Fraternity)
  }
  
  fileprivate func add(fraternity frat : Fraternity) throws {
    if let _ = fraternitiesByName[frat.name] {
      throw CampusError.duplicateRegistration(fraternity: frat)
    }
    else {
      self.fraternitiesByKey[frat.key] = frat
      self.fraternitiesByName[frat.name] = frat
    }
  }
}
extension Campus {
  // Returns whether the Fraternity is now a favorite
  func toggleFavorite(named fratName : String) -> Bool {
    return unfavorite(fratNamed: fratName) ? false : favorite(fratNamed: fratName)
  }
}

extension Fraternity {
  func register(withCampus campus : Campus) {
    do {
      try campus.add(fraternity: self)
    }
    catch let e {
      switch e {
      case Campus.CampusError.registrationError(fraternity:):
        print("Fraternity Error:\n\tCannot add \(name) (\(description)) to the Campus.")
      case Campus.CampusError.duplicateRegistration(fraternity:):
        print("Fraternity Error:\n\tDuplicate registration of \(name) (\(description)).")
      default:
        print("Unknown Campus Error...")
      }
    }
  }
  
  
}







