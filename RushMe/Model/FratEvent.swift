//
//  FratEvent.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class FratEvent: NSObject {
  private var calendar = Calendar.current
  private var startTime = Date()
  private var endTime = Date()
  private var name : String
  private var location : String?
  private var frat : Fraternity?
  
  init?(withName : String, onDate : String, ownedByFraternity : Fraternity, startingAt : String? = nil, endingAt : String? = nil, atLocation : String? = nil) {
    self.name = withName
    self.frat = ownedByFraternity
    self.location = atLocation
    let dateArr = onDate.split(separator: "/")
    if (dateArr.count != 3){
      return nil
    }
  
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
          startTime = DateComponents(calendar: self.calendar, year: year, month: month, day: day, hour: startHour, minute: startMin).date!
          if let _ = endingAt {
            let splitEndingTime = endingAt!.split(separator: ":")
            endHour = NumberFormatter().number(from: String(splitEndingTime[0]))?.intValue
            endMin = NumberFormatter().number(from: String(splitEndingTime[1]))?.intValue
          }
          endTime = DateComponents(calendar: self.calendar, year: year, month: month, day: day, hour: endHour, minute: endMin).date!
          return
        }
      }
    }
    return nil
    
    
    
    
    
  }
  func getStartDate() -> Date {
    return startTime
  }
  func getName() -> String {
    return name
  }
  func getOwningFrat() -> Fraternity {
    return frat!
  }
  func getLocation() -> String? {
    return location
  }
  
  private func formatToHour(date : Date) -> String {
    let time = DateFormatter.localizedString(from: date,
                                             dateStyle: DateFormatter.Style.none,
                                             timeStyle: DateFormatter.Style.full)
    let AmPm = String(time.split(separator: " ")[1])
    let split = time.split(separator: ":")
    let hour = String(split[0])
    let min = String(split[1])
    return hour + ":" +  min + " " + AmPm
    
  }
  
  func getEndHours() -> String {
    return formatToHour(date: self.endTime)
  }
  func getStartHour() -> String {
    return formatToHour(date: self.startTime)
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  

}
