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


class Campus: NSObject {
  // MARK: Member Variables
  // The user's favorite fraternities
  private(set) var favoritedFrats = Set<String>() {
    willSet {
      self.saveFavorites()
      self.firstFavoritedEvent_ = nil
      self.eventsByDay_ = nil
      self.favoritedEvents_ = nil
      self.favoritedEventsByDay_ = nil
    }
  }
  func addFavorite(named newFavorite : String) {
    if fraternityNames.contains(newFavorite) {
      if favoritedFrats.insert(newFavorite).inserted {
        Backend.inform(action: .FraternityFavorited, options: newFavorite)
      }
    }
  }
  func removeFavorite(named oldFavorite : String) {
    if favoritedFrats.contains(oldFavorite) {
      favoritedFrats.remove(oldFavorite)
      Backend.inform(action: .FraternityUnfavorited, options: oldFavorite)
    }
  }
  
  var hasFavorites : Bool {
    return !(fraternitiesByName.isEmpty || favoritedFrats.isEmpty)
  }
  // The name of every fraternity, in download order
  private(set) var fraternityNamesObservable = Observable<Set<String>>(Set<String>())
  @objc private(set) var fraternityNames = Set<String>() {
    willSet {
      fraternityNamesObservable.value = newValue
    }
  }
  // Refer to each fraternity by its name, in no order
  private(set) var fraternitiesByName = [String : Fraternity]()
  // FratEvents, unordered
  private var favoritedEvents_ : Set<Fraternity.Event>? = nil
  var favoritedEvents : Set<Fraternity.Event> {
    get {
      if favoritedEvents_ == nil {
        favoritedEvents_ = self.allEvents.filter({ (event) -> Bool in
          return self.favoritedFrats.contains(event.frat.name) && (considerPastEvents || event.startDate.compare(.today) != .orderedAscending)
        })
      }
      return favoritedEvents_ ?? self.favoritedEvents
    }
  }
  private var eventsByDay_ : [[Fraternity.Event]]? = nil
  var eventsByDay : [[Fraternity.Event]] {
    get {
      if eventsByDay_ == nil {
        eventsByDay_ = [[Fraternity.Event]]()
        for daysEvents in fratEventsByDay.values {
          let futureDaysEvents = daysEvents.filter({ (event) -> Bool in
            return considerPastEvents || event.startDate.compare(.today) != .orderedAscending
          }).sorted { (first, second) -> Bool in
            return first.startDate < second.startDate 
          }
          if futureDaysEvents.count > 0 {
            eventsByDay_!.append(futureDaysEvents)
          }
        }
        eventsByDay_!.sort(by: { (first, second) -> Bool in
          return first[0].startDate < second[0].startDate
        })
      }
      return eventsByDay_!
    }
  }
  private var favoritedEventsByDay_ : [[Fraternity.Event]]? = nil
  var favoritedEventsByDay : [[Fraternity.Event]] {
    get {
      if favoritedEventsByDay_ == nil {
        favoritedEventsByDay_ = [[Fraternity.Event]]()
        for daysEvents in eventsByDay {
          let favoritedEventsToday = daysEvents.filter({ (event) -> Bool in
            return favoritedFrats.contains(event.frat.name)
          }).sorted { (first, second) -> Bool in
            return first.startDate < second.startDate
          }
          if !favoritedEventsToday.isEmpty {
            favoritedEventsByDay_!.append(favoritedEventsToday)
          }
        }
      }
      return favoritedEventsByDay_!
    }
  }
  private var fratEventsByDay = [String : [Fraternity.Event]]()
  private(set) var allEvents = Set<Fraternity.Event>()
  private var firstFavoritedEvent_ : Fraternity.Event? = nil
  var firstFavoritedEvent : Fraternity.Event? {
    get {
      if firstFavoritedEvent_ == nil {
        firstFavoritedEvent_ = favoritedEvents.filter({ (event) -> Bool in
          return considerPastEvents || event.startDate > .today
        }).min(by: {
          (thisEvent, thatEvent) in
          return thisEvent.startDate < thatEvent.startDate
        })
      }
      return firstFavoritedEvent_
    }
  }
  private var firstEvent_ : Fraternity.Event? = nil
  var firstEvent : Fraternity.Event? {
    get {
      if firstEvent_ == nil {
        firstEvent_ = allEvents.filter({ (event) -> Bool in
          return considerPastEvents || event.startDate > .today
        }).min(by: {
          (thisEvent, thatEvent) in
          return thisEvent.startDate < thatEvent.startDate
        })
      }
      return firstEvent_
    }
  }
  
  
  // The default quality at which an image should be downloaded
  static var downloadedImageQuality : Quality = .Medium
  var considerPastEvents : Bool {
    get {
      return User.preferences.considerPastEvents
    }
    set {
      if newValue != User.preferences.considerPastEvents {
        self.firstFavoritedEvent_ = nil
        self.eventsByDay_ = nil
        self.favoritedEvents_ = nil
        self.favoritedEventsByDay_ = nil 
      }
      User.preferences.considerPastEvents = newValue
    }
    
  }
  // MARK: Shared Instance (singleton)
  @objc static let shared : Campus = Campus(loadFromFile: true)
  
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
        
        for fraternityDict in dictArray {
          _ = Fraternity(withDictionary: fraternityDict)?.register(withCampus: self)
          // Removed due to performance issues, lack of necessity for small quantity of data being pulled
//          self.percentageCompletionObservable.value = 0.2 + 0.8*Float(numberFraternitiesCompleted) / Float(dictArray.count)
        }
        for eventDict in eventArray {
          if let fratName = eventDict["house"] as? String, 
             let fEvent = self.fraternitiesByName[fratName]?.add(eventDescribedBy: eventDict){
            if let _ = self.fratEventsByDay[fEvent.dayKey] {
              self.fratEventsByDay[fEvent.dayKey]!.append(fEvent)
            } else {
              self.fratEventsByDay[fEvent.dayKey] = [fEvent] 
            }
            self.allEvents.insert(fEvent)
          }
        }
        self.percentageCompletion = 1
        DispatchQueue.main.async {
          Locations.geocode(selectedFraternities: Array(Campus.shared.fraternityNames))
        }
        

        
      } 
    }
    else {
      print("(Tried to refresh when loading)") 
    }
    
    
  }
  
  // Allows fraternity favorites to be loaded from a file
  fileprivate convenience init(loadFromFile : Bool) {
    self.init()
    if loadFromFile {
      // TODO: Refactor storing of user preferences
      DispatchQueue.global(qos: .default).async {
        if let favorites = Campus.loadFavorites() {
          self.favoritedFrats = favorites
        }
        else {
          self.saveFavorites()
        }
      }
      
    }
  }
  enum CampusError : Error {
    case RuntimeError(String)
  }
  fileprivate func add(fraternity frat : Fraternity) throws {
    if let _ = fraternitiesByName[frat.name] {
      throw CampusError.RuntimeError("Fraternity \(frat.name) trying to register twice!")
    }
    else {
      self.fraternitiesByName[frat.name] = frat
      self.fraternityNames.insert(frat.name)
    }
    
  }
  @objc func getEvents(forFratWithName fratName : String, async : Bool = false) -> [Date: Fraternity.Event] {
    if let events = Campus.shared.fraternitiesByName[fratName]?.events {
      // If is fraternity's list of events is already saturated, return
      return events 
    }
    else {
      return [Date : Fraternity.Event]() 
    }
  }
  // MARK: Save To and Load From File
  func saveFavorites() {
    DispatchQueue.global(qos: .background).async {
      UserDefaults.standard.set(Array(self.favoritedFrats), forKey: "Favorites")
    }
  }
  static private func loadFavorites() -> Set<String>? {
    if let favoritedFrats = UserDefaults.standard.stringArray(forKey: "Favorites") {
      return Set<String>(favoritedFrats)
    }
    else {
      print("Error loading favorite frats from: \(User.files.favoritedFratURL.path)")
      return nil
    }
  }
}
extension Campus {
  // Returns whether the Fraternity is now a favorite
  func toggleFavorite(named fratName : String) -> Bool {
    if favoritedFrats.contains(fratName) {
      removeFavorite(named: fratName) 
      return false
    }
    else {
      addFavorite(named: fratName)
      return true
    }
    
  }
}

extension Fraternity {
  func register(withCampus campus : Campus) -> Fraternity {
    do {
      try campus.add(fraternity: self)
    }
    catch let e {
      print(e.localizedDescription)
    }
    return self
  }
  
  
}







