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
  private(set) var startDate : Date = Date()
  private(set) var endDate = Date()
  private(set) var name : String
  private(set) var location : String?
  private(set) var frat : Fraternity
  
  init?(withName : String,
        onDate : String,
        ownedByFraternity : Fraternity,
        startingAt : String? = nil,
        endingAt : String? = nil,
        atLocation : String? = nil) {
    self.name = withName
    self.frat = ownedByFraternity
    self.location = atLocation
    let dateArr = onDate.split(separator: "/")
    if (dateArr.count != 3){ return nil }
    
    if let year = NumberFormatter().number(from: String(dateArr[2]))?.intValue {
      if let month = NumberFormatter().number(from: String(dateArr[0]))?.intValue {
        if let day = NumberFormatter().number(from: String(dateArr[1]))?.intValue {
          var startHour : Int? = nil
          var startMin : Int? = nil
          var endHour : Int? = nil
          var endMin : Int? = nil
          if let _ = startingAt {
            let splitStartingTime = startingAt!.split(separator: ":")
            startHour = NumberFormatter().number(from: String(splitStartingTime[0]))?.intValue
            startMin = NumberFormatter().number(from: String(splitStartingTime[1]))?.intValue
            endHour = startHour
            endMin = startMin
          }
          startDate = DateComponents(calendar: self.calendar,
                                     year: year, month: month, day: day, hour: startHour, minute: startMin).date!
          //          if Date().compare(startDate) == ComparisonResult.orderedDescending {
          //            return nil
          //          }
          if let _ = endingAt {
            let splitEndingTime = endingAt!.split(separator: ":")
            endHour = NumberFormatter().number(from: String(splitEndingTime[0]))?.intValue
            endMin = NumberFormatter().number(from: String(splitEndingTime[1]))?.intValue
          }
          if let _ = startHour {
            endHour = startHour! + 1
          }
          endDate = DateComponents(calendar: self.calendar,
                                   year: year, month: month, day: day, hour: endHour, minute: endMin).date!
          return
        }
      }
    }
    return nil
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
