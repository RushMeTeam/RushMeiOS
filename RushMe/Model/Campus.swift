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
fileprivate let campusSharedInstance = Campus()
// Describe three quality metrics
enum Quality {
  case High
  case Medium
  case Low
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
  // The user's favorite fraternities
  var favoritedFrats = [String]()
  
  // The name of every fraternity, in download order
  var fratNames = [String]()
  // Refer to each fraternity by its name, in no order
  var fraternitiesDict = [String : Fraternity]()
  // FratEvents, unordered
  private(set) var favoritedFratEvents = Set<FratEvent>()
  private var allEvents = Set<FratEvent>()
  // The default quality at which an image should be downloaded
  var downloadedImageQuality : Quality = .Medium
  
  // Remove any FratEvents that are not from favorited frats
  func filterEventsForFavorites()  {
    let favoriteSet = Set.init(favoritedFrats)
    var newEvents = Set<FratEvent>()
    for event in allEvents {
      if favoriteSet.contains(event.frat.name) {
        // If not considering events before today and this event is not after today
        if !considerEventsBeforeToday && event.startDate.compare(Date()) == .orderedAscending {
          continue
        }
        newEvents.insert(event)
      }
    }
    favoritedFratEvents = newEvents
  }
  var considerEventsBeforeToday = true
  static var shared : Campus {
    get {
      return campusSharedInstance
    }
  }
  
  // Create an URL that descibes the location of an image on a server,
  // then (try to!) download the images. If anything goes wrong, return
  // nil
  func pullImage(fromSource : String) -> UIImage? {
    var fileName = ""
    // Images are scaled to three different sizes:
    //    - high (i.e. full)
    //    - medium (i.e. half-size)
    //    - low (i.e. quarter-size)
    // The quality of the image retreived is based on the
    // file URL. For example, a file named "image.png" would
    // have a half-sized image named "image_Half.png"
    switch downloadedImageQuality {
    case .High:
      fileName = fromSource
    case.Medium:
      fileName = fromSource.dropLast(4) + RMImageQuality.Medium
    case.Low:
      fileName = fromSource.dropLast(4) + RMImageQuality.Low
    }
    if (DEBUG) { print(fileName, separator: "", terminator: "") }
    let urlAsString = RMNetwork.HTTP +  fileName
    var image : UIImage? = nil
    // Try to create an URL from the string-- upon fail return nil
    if let url = URL(string: urlAsString) {
      if (DEBUG) { print(".", separator: "", terminator: "") }
      // Try to retreive the image-- upon fail return nil
      if let data = try? Data.init(contentsOf: url){
        if (DEBUG) { print(".", separator: "", terminator: "") }
        // Try to downcase the retreived data to an image
        if let im = UIImage(data: data) {
          image = im
          if (DEBUG) { print(".Done", separator: "", terminator: "") }
        }
      }
    }
    if (DEBUG) { print("") }
    // May be nil!
    return image
  }
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
      DispatchQueue.global(qos: .userInitiated).async {
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
      if let fratEvents = sharedSQLHandler.select(fromTable : "events",
                                                  whereClause: "house = '" + fratName + "'") {
        for eventDict in fratEvents {
          if let fEvent = fraternity.add(eventDescribedBy: eventDict, ownedBy: fraternity) {
            campusSharedInstance.favoritedFratEvents.insert(fEvent)
            campusSharedInstance.allEvents.insert(fEvent)
          }
        }
      }
      return fraternity.events
    }
    // Failed, provide no dates
    return [Date : FratEvent]()
  }
}

