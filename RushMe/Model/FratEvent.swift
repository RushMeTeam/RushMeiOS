//
//  FratEvent.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class FratEvent: NSObject {
  private(set) var calendar = Calendar.current
  private(set) var startDate : Date
  private(set) var endDate : Date
  private(set) var name : String
  private(set) var location : String?
  private(set) var frat : Fraternity

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
    
    
    self.startDate = ((startingAt == nil) ? RushMe.dateFormatter.date(from: onDate) : RushMe.dateTimeFormatter.date(from: onDate + " " + startingAt!))!
    self.endDate = ((endingAt == nil) ? startDate : RushMe.dateTimeFormatter.date(from: onDate + " " + endingAt!))!
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  var dayKey : String {
    return DateFormatter.localizedString(from: self.startDate, dateStyle: .medium, timeStyle: .none)
  }
  static func <(lhs : FratEvent, rhs : FratEvent) -> Bool {
   return lhs.startDate < rhs.startDate 
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
