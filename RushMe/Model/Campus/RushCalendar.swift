//
//  CalendarManager.swift
//  
//
//  Created by Adam Kuniholm on 11/11/17.
//

import UIKit
import iCalKit
/*
 A shared group of calendars containing events -- shared
 in order to maintain continuity between multiple exports,
 fileprivate because continuity must only be held between
 exports, and no other components of the application require
 information from or modification of the variable.
 */

//fileprivate let eventStore = EKEventStore()
/*
 A static class used to export events into two locations:
 - iCal, the default calendar application on any device
 - an .ics file, the standard calendar event file,
 compatible with any and all calendar services, such
 as Google calendar
 Note that although exportAsICS simply saves an ICS file to disk,
 exportToCalendar actually mutates the users' calendar (with
 permission) as to actually do the work.
 */



class RushCalendar {
  static let shared : RushCalendar = RushCalendar()
  private var events : [Int : Set<Fraternity.Event>] = [Int : Set<Fraternity.Event>]()
  
  func add(event : Fraternity.Event) -> Bool {
    let key = event.startDate.daysSinceReferenceDate
    if let _ = events[key] {
      return events[key]!.insert(event).inserted
    } else {
      events[key] = Set([event])
      return true
    }
  }
  
  func remove(event: Fraternity.Event) -> Bool {
    guard let daysEvents = events[event.startDate.daysSinceReferenceDate] else {
     return false 
    }; guard daysEvents.count > 1 else {
     return events.removeValue(forKey: event.startDate.daysSinceReferenceDate) != nil
    }
    return events[event.startDate.daysSinceReferenceDate]!.remove(event) != nil
  }
  
  var firstDate : Date? {
    get {
     return firstEvent?.startDate 
    }
  }
  
  var firstEvent : Fraternity.Event? {
    get {
      guard let key = events.keys.min() else {
        return nil 
      }
      return events[key]?.min(by: <)
    }
  }
  
  var hasEvents : Bool {
    get {
     return !events.isEmpty 
    }
  }
  
  func eventsOn(_ date : Date) -> Set<Fraternity.Event>? {
    return events[date.daysSinceReferenceDate]
  }
}

extension Date {
  var daysSinceReferenceDate : Int {
    return Int(timeIntervalSinceReferenceDate/86400) 
  }
}

extension Collection where Element : Fraternity.Event {
  var asICS : String {
    get {
      var iCalEvents = [Event]()
      // Run through the FratEvents, add as much information
      // about each as possible.
      
      for event in self {
        var iCalEvent = Event()
        iCalEvent.dtstart = event.startDate
        iCalEvent.dtend = event.endDate
        iCalEvent.location = event.location
        iCalEvent.summary = event.name
        iCalEvents.append(iCalEvent)
      }
      // Compose a calendar, combining the events dynamically
      // into the VCalendar format.
      // The heavy-lifting is done here: translate the calendar
      // into its text-equivalent
      return Calendar(withComponents: iCalEvents).toCal()
    }
  }
}

