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
  private(set) var events : Set<Fraternity.Event> = Set<Fraternity.Event>()
  private(set) var eventsByDay : [Date : Set<Fraternity.Event>] = [Date : Set<Fraternity.Event>]()
  private(set) var eventsByFraternity : [Fraternity : Set<Fraternity.Event>] = [Fraternity : Set<Fraternity.Event>]()
  func add(event : Fraternity.Event) -> Bool {
    let _ = events.insert(event)
    if eventsByFraternity[event.frat] == nil{
      eventsByFraternity[event.frat] = Set<Fraternity.Event>()
    }
    let key = event.starting.dayDate
    if eventsByDay[key] == nil {
     eventsByDay[key] = Set<Fraternity.Event>() 
    } 
    return eventsByDay[key]!.insert(event).inserted && 
           eventsByFraternity[event.frat]!.insert(event).inserted
  }
  
  func remove(event: Fraternity.Event) -> Bool {
    let _ = events.remove(event)
    if let events = eventsByFraternity[event.frat], events.count > 1  {
     eventsByFraternity[event.frat]?.remove(event)
    } else {
     eventsByFraternity.removeValue(forKey: event.frat) 
    }
    guard let daysEvents = eventsByDay[event.starting.dayDate] else {
     return false 
    }; guard daysEvents.count > 1 else {
     return eventsByDay.removeValue(forKey: event.starting.dayDate) != nil
    }
    return eventsByDay[event.starting.dayDate]!.remove(event) != nil
  }
 
  
  var firstDate : Date? {
    get {
     return firstEvent?.starting.dayDate 
    }
  }
  
  var firstEvent : Fraternity.Event? {
    get {
      guard let key = eventsByDay.keys.min() else {
        return nil 
      }
      return eventsByDay[key]?.min(by: <)
    }
  }
  
  var hasEvents : Bool {
    get {
     return !eventsByDay.isEmpty 
    }
  }
  
  func eventsOn(_ date : Date) -> Set<Fraternity.Event>? {
    return eventsByDay[date.dayDate]?.filter({ (event) -> Bool in
      return User.preferences.considerPastEvents
        || event.ending > (User.debug.debugDate ?? Date())
    })
  }
}

extension Date {
  var daysSinceReferenceDate : Int {
    let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
    let components  = Calendar.current.dateComponents([.day], from: referenceDate, to: self)
    return components.day ?? Int(timeIntervalSinceReferenceDate/86400)
  }
  var dayDate : Date {
    var components = Calendar.current.dateComponents([.day, .month, .year], from: self)
    components.hour = 0
    components.minute = 0
    components.second = 0
    return Calendar.current.date(from: components)!
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
        iCalEvent.dtstart = event.starting
        iCalEvent.dtend = event.ending
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
extension Fraternity {
  var events : Set<Fraternity.Event>? {
    return RushCalendar.shared.eventsByFraternity[self]
  }
}
