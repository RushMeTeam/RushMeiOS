//
//  Campus.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

let campusSharedInstance = Campus()

class Campus: NSObject {
  var favorites = [String]()
  var fratNames = [String]()
  var fraternities = [String : Fraternity]()
  var events = Set<FratEvent>()
  func filterEventsForFavorites()  {
    let favoriteSet = Set.init(favorites)
    var newEvents = Set<FratEvent>()
    for event in events {
      if favoriteSet.contains(event.getOwningFrat().name) {
        newEvents.insert(event)
      }
    }
    events = newEvents
    
  }
}


