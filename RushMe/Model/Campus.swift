//
//  Campus.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

let campusSharedInstance = Campus()

enum Quality {
  case High
  case Medium
  case Low
}

class Campus: NSObject {
  var favorites = [String]()
  var fratNames = [String]()
  var fraternities = [String : Fraternity]()
  var events = Set<FratEvent>()
  var quality : Quality = .High
  func filterEventsForFavorites()  {
    let favoriteSet = Set.init(favorites)
    var newEvents = Set<FratEvent>()
    for event in events {
      if favoriteSet.contains(event.frat.name) {
        newEvents.insert(event)
      }
    }
    events = newEvents
    
  }
  
  func pullImage(fromSource : String) -> UIImage? {
    let downsize = fromSource//.dropLast(4) //+ "_Quarter.png.png"
    print(downsize + " Done")
    var image : UIImage? = nil
    let urlAsString = "http://" + NETWORK.IP + "/" + downsize
    if let url = URL(string: urlAsString) {
      if let data = try? Data.init(contentsOf: url){
        if let im = UIImage(data: data) {
          image = im
          
        }
      }
    }
    return image
  }
  @objc func getEvents(forFratWithName fratName : String, async : Bool = false) -> [Date: FratEvent] {
    if let events = campusSharedInstance.fraternities[fratName]?.events {
      if events.count > 0 {
        return events
      }
    }
    if (async) {
      DispatchQueue.global(qos: .userInitiated).async {
        let _ = pullEventsFromSQLDataBase(fratName: fratName)
      }
      return [Date : FratEvent]()
    }
    return pullEventsFromSQLDataBase(fratName : fratName)
    
    
  }
}

private func pullEventsFromSQLDataBase(fratName : String) -> [Date : FratEvent] {
  if let fraternity = campusSharedInstance.fraternities[fratName] {
    if let fratEvents = sharedSQLHandler.select(fromTable : "events",
                                                whereClause: "house = '" + fratName + "'") {
      for eventDict in fratEvents {
        if let fEvent = fraternity.add(eventDescribedBy: eventDict, ownedBy: fraternity) {
          campusSharedInstance.events.insert(fEvent)
        }
      }
    }
    return fraternity.events
  }
  return [Date : FratEvent]()
}


