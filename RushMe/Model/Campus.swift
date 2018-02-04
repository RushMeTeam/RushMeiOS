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
fileprivate let campusSharedInstance = Campus(loadFromFile: true)
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
  var favoritedFrats = [String]() {
    didSet {
      self.saveFavorites()
      self.firstEvent_ = nil
      self.eventsByDay_ = nil
      self.favoritedEvents_ = nil
      self.favoritedEventsByDay_ = nil
    }
  }
  var hasFavorites : Bool {
    return !favoritedFrats.isEmpty
  }
  // The name of every fraternity, in download order
  var fratNames = [String]()
  // Refer to each fraternity by its name, in no order
  var fraternitiesDict = [String : Fraternity]()
  // FratEvents, unordered
  private var favoritedEvents_ : Set<FratEvent>? = nil
  var favoritedEvents : Set<FratEvent> {
    get {
      if favoritedEvents_ == nil {
        favoritedEvents_ = self.allEvents.filter({ (event) -> Bool in
          return self.favoritedFrats.contains(event.frat.name) && (considerEventsBeforeToday || event.startDate.compare(RMDate.Today) != .orderedAscending)
        })
      }
      return favoritedEvents_!
    }
  }
  private var eventsByDay_ : [[FratEvent]]? = nil
  var eventsByDay : [[FratEvent]] {
    get {
      if eventsByDay_ == nil {
        eventsByDay_ = [[FratEvent]]()
        for daysEvents in fratEventsByDay.values {
          let futureDaysEvents = daysEvents.filter({ (event) -> Bool in
            return considerEventsBeforeToday || event.startDate.compare(RMDate.Today) != .orderedAscending
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
  private var favoritedEventsByDay_ : [[FratEvent]]? = nil
  var favoritedEventsByDay : [[FratEvent]] {
    get {
      if favoritedEventsByDay_ == nil {
        favoritedEventsByDay_ = [[FratEvent]]()
        for daysEvents in eventsByDay {
          let favoritedEventsToday = daysEvents.filter({ (event) -> Bool in
            return favoritedFrats.contains(event.frat.name)
          })
          if !favoritedEventsToday.isEmpty {
            favoritedEventsByDay_!.append(favoritedEventsToday)
          }
        }
      }
      return favoritedEventsByDay_!
    }
  }
  private var fratEventsByDay = [String : [FratEvent]]()
  private var allEvents = Set<FratEvent>()
  private var firstEvent_ : FratEvent? = nil
  var firstEvent : FratEvent? {
    get {
      if firstEvent_ == nil {
        firstEvent_ = favoritedEvents.min(by: {
          (thisEvent, thatEvent) in
          return thisEvent.startDate.compare(thatEvent.startDate) == ComparisonResult.orderedAscending
        })
      }
      return firstEvent_
    }
  }
  
  // The default quality at which an image should be downloaded
  var downloadedImageQuality : Quality = .Medium
  var considerEventsBeforeToday = true {
    willSet {
      if newValue != self.considerEventsBeforeToday {
        self.firstEvent_ = nil
        self.eventsByDay_ = nil
        self.favoritedEvents_ = nil
        self.favoritedEventsByDay_ = nil 
      }
    }
    didSet {
      preferences[RMPropertyKeys.ConsiderEventsBeforeTodayKey] = considerEventsBeforeToday
    }
  }
  private(set) var firstLoad : Bool = false
  private var preferences : Dictionary<String, Any> = Dictionary<String, Any>() {
    didSet {
      DispatchQueue.global().async {
        if NSKeyedArchiver.archiveRootObject(self.preferences, toFile: RMFileManagement.userInfoURL.path) {
          //print("Success saving Campus preferences")
        }
        else {
          print("Failed to save Campus preferences!")
        }
      }
    }
  }
  
  // MARK: Shared Instance (singleton)
  static var shared : Campus {
    get {
      return campusSharedInstance
    }
  }
  // Allows fraternity favorites to be loaded from a file
  fileprivate convenience init(loadFromFile : Bool) {
    self.init()
    if loadFromFile {
      if let preferencesObject = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.userInfoURL.path) as? Dictionary<String, Any>,
        let considerEventsBeforeTodayValue = preferencesObject[RMPropertyKeys.ConsiderEventsBeforeTodayKey] as? Bool {
        self.considerEventsBeforeToday = considerEventsBeforeTodayValue
      }
      else {
        print("Failed to load Preferences")
      }
      DispatchQueue.global(qos: .default).async {
        if let favorites = Campus.loadFavorites() {
          self.favoritedFrats = favorites
          self.firstLoad = false
        }
        else {
          self.firstLoad = true
          self.saveFavorites()
        }
      }
      
    }
  }
  enum CampusError : Error {
    case RuntimeError(String)
  }
  fileprivate func add(fraternity frat : Fraternity) throws {
    if let _ = fraternitiesDict[frat.name] {
      throw CampusError.RuntimeError("Fraternity \(frat.name) trying to register twice!")
    }
    else {
      self.fraternitiesDict[frat.name] = frat
      self.fratNames.append(frat.name)
      DispatchQueue.global().async {
        let _ = self.getEvents(forFratWithName: frat.name)
      }
    }
    
  }
  // Remove any FratEvents that are not from favorited frats
  //  func filterEventsForFavorites()  {
  //    let favoriteSet = Set.init(favoritedFrats)
  //    var newEventsByDay = [String : [FratEvent]]()
  //    var newEvents = Set<FratEvent>()
  //    for event in allEvents {
  //      if favoriteSet.contains(event.frat.name) {
  //        // If not considering events before today and this event is not after today
  //        if !considerEventsBeforeToday && event.startDate.compare(RMDate.Today) == .orderedAscending {
  //          continue
  //        }
  //        if let _ = newEventsByDay[event.dayKey] {
  //          print("did this")
  //          newEventsByDay[event.dayKey]!.append(event)
  //        }
  //        else {
  //          newEventsByDay[event.dayKey] = [event]
  //        }
  //        newEvents.insert(event)
  //      }
  //    }
  //    favoritedEvents = newEvents
  //  }
  
  // Create an URL that descibes the location of an image on a server,
  // in addition to a local URL. Then (try to!) (down)load the image. 
  // If anything goes wrong, return nil
  
  // Pull all the images for a given fraternity name, with the
  // option of asynchronous loading:
  //    - if async == true, image is loaded in a new thread, nothing interesting is returned
  //    - else image is loaded sequentially, and main thread waits
  // Note that if the events for this fraternity have already been loaded,
  // The function simply returns those events
  @objc func getEvents(forFratWithName fratName : String, async : Bool = false) -> [Date: FratEvent] {
    if let events = campusSharedInstance.fraternitiesDict[fratName]?.events {
      // If is fraternity's list of events is already saturated, return
      if events.count > 0 { return events }
    }
    // If asynchronous loading is enabled
    if (async) {
      // Dispatch a new relatively high priority thread to get the images
      DispatchQueue.global(qos: .default).async {
        let _ = self.pullEventsFromSQLDataBase(fratName: fratName)
      }
      return [Date : FratEvent]() // return an empty dictionary for the meantime
    }
    // If not asyncrhonous, call function in (presumably) main thread
    return pullEventsFromSQLDataBase(fratName : fratName)
  }
  
  private func pullEventsFromSQLDataBase(fratName : String) -> [Date : FratEvent] {
    // Try to grab the fraternity (see if it exists)
    if let fraternity = self.fraternitiesDict[fratName] {
      // Pull all this house's events from the SQL database
      if let fratEvents = SQLHandler.shared.select(fromTable: "events", conditions: "house = '" + fratName + "'") {
        for eventDict in fratEvents {
          if let fEvent = fraternity.add(eventDescribedBy: eventDict, ownedBy: fraternity) {
            if let _ = fratEventsByDay[fEvent.dayKey] {
              fratEventsByDay[fEvent.dayKey]!.append(fEvent)
            }
            else {
              fratEventsByDay[fEvent.dayKey] = [fEvent] 
            }
            self.allEvents.insert(fEvent)
          }
        }
      }
      return fraternity.events
    }
    print("Failed to return \(fratName)'s events")
    // Failed, provide no dates
    return [Date : FratEvent]()
  }
  // MARK: Save To and Load From File
  func saveFavorites() {
    DispatchQueue.global(qos: .background).async {
      let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Campus.shared.favoritedFrats, toFile: RMFileManagement.favoritedFratURL.path)
      if !isSuccessfulSave {
        print("Error saving favorite frats at: \(RMFileManagement.favoritedFratURL.path)")
      }
    }
  }
  static private func loadFavorites() -> [String]? {
    if let favoritedFrats = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.favoritedFratURL.path) as? [String] {
      return favoritedFrats
    }
    else {
      print("Error loading favorite frats from: \(RMFileManagement.favoritedFratURL.path)")
      return nil
    }
  }
}
extension Fraternity {
  convenience init?(fromDict dict : Dictionary<String, Any>, loadImages : Bool = true) {
    if let name = dict[RMDatabaseKey.NameKey] as? String,
      let chapter = dict[RMDatabaseKey.ChapterKey] as? String {
      var previewImage : UIImage?
      var profileImage : UIImage?
        if let URLString = dict[RMDatabaseKey.ProfileImageKey] as? String {
          if let previewImg = pullImage(fromSource: URLString) {
            previewImage = previewImg
            profileImage = previewImg
          }
        }
      self.init(name: name, chapter: chapter, previewImage: previewImage, properties: dict)
      if let _ = profileImage {
        self.setProperty(named: RMDatabaseKey.ProfileImageKey, to: profileImage!)
      }
//      if loadImages {
//        if let URLString = self.getProperty(named: RMDatabaseKey.CalendarImageKey) as? String {
//          if let calendarImg = pullImage(fromSource: URLString) {
//            self.setProperty(named: RMDatabaseKey.CalendarImageKey, to: calendarImg)
//          }
//        }
        
        // Get the CoverImage
        //                  if let URLString = dict[RMDatabaseKey.CoverImageKey] as? String {
        //                    DispatchQueue.global().async {
        //                      if let coverImg = Campus.shared.pullImage(fromSource: URLString) {
        //                        frat.setProperty(named: RMDatabaseKey.CoverImageKey, to: coverImg)
        //                      }
        //                    }
        //                  }
//              }
      return

    }
    
    return nil
  }
  func register(withCampus campus : Campus) {
    do {
      try campus.add(fraternity: self)
    }
    catch let e {
     print(e.localizedDescription)
    }
  }
  
  
}

func urlSuffix(forFileWithName urlSuffix : String, quality : Quality = Campus.shared.downloadedImageQuality) -> String {
  var fileName = ""
  // Images are scaled to three different sizes:
  //    - high (i.e. full)
  //    - medium (i.e. half-size)
  //    - low (i.e. quarter-size)
  // The quality of the image retreived is based on the
  // file URL. For example, a file named "image.png" would
  // have a half-sized image named "image_Half.png"
  switch quality {
  case .High:
    // Frat_Info_Pics/Sigma_Delta_Cover_Image.png
    fileName = urlSuffix
  case.Medium:
    // Frat_Info_Pics/Sigma_Delta_Cover_Image_half.png
    fileName = urlSuffix.dropLast(4) + RMImageQuality.Medium
  case.Low:
    // Frat_Info_Pics/Sigma_Delta_Cover_Image_quarter.png
    fileName = urlSuffix.dropLast(4) + RMImageQuality.Low
  }
  // Sigma_Delta_Cover_Image.png
  
  // .../local/on/device/path/Sigma_Delta_Cover_Image.png
  return fileName
}

func urlSuffixes(forFilesWithName filename : String) -> [String] {
 return [urlSuffix(forFileWithName: filename, quality: .Low), urlSuffix(forFileWithName: filename, quality: .Medium), urlSuffix(forFileWithName: filename, quality: .High)]
}

func pullImage(fromSource : String, quality : Quality = Campus.shared.downloadedImageQuality) -> UIImage? {
  if !FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path) {
    do {
      try FileManager.default.createDirectory(at: RMFileManagement.fratImageURL, withIntermediateDirectories: false, attributes: nil)
    }
    catch let e {
     print(e.localizedDescription)
    }
  }
  let fixedPath = urlSuffix(forFileWithName: fromSource, quality : quality)
  let urlEnding = String(fixedPath.split(separator: "/").last!)
  let localFileURL = RMFileManagement.fratImageURL.appendingPathComponent(urlEnding)
  if let imageData = try? Data.init(contentsOf: localFileURL),
    let image = UIImage.init(data: imageData){
    return image
  }
  //if (DEBUG) { print(fileName, separator: "", terminator: "") }
  let urlAsString = RMNetwork.HTTP + fixedPath
  var image : UIImage? = nil
  // Try to create an URL from the string-- upon fail return nil
  if let url = URL(string: urlAsString) {
    //if (DEBUG) { print(".", separator: "", terminator: "") }
    // Try to retreive the image-- upon fail return nil
    if let data = try? Data.init(contentsOf: url){
      //if (DEBUG) { print(".", separator: "", terminator: "") }
      // Try to downcase the retreived data to an image
      if let img = UIImage(data: data) {
        image = img
        if let imageData = UIImagePNGRepresentation(img) {
          DispatchQueue.global(qos: .background).async {
            do {
              try imageData.write(to: localFileURL)
            }
            catch let e {
              print(e.localizedDescription)
            }
          }
        }
        //if (DEBUG) { print(".Done", separator: "", terminator: "") }
      }
    }
  }
  //if (DEBUG) { print("") }
  // May be nil!
  return image
}

