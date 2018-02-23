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
class RMCalendarManager {

  /*
  Export FratEvents to the device's default calendar application.
  
   Each FratEvent is translated into its most pertinent event
   information, then, unless there is already one in the user's
   calendar app, creates a custom "RushMe Frat Events" calendar
   colored with the app's default color (see Contants->COLOR_CONST)
 */
  /*
  static func exportToCalendar(events : [FratEvent]) -> (didSucceed : Bool, withDetails : String) {
    if (events.count == 0){
        return (false, "No events to add")
    }
    var result = (false, "Unknown error occured")
    var calendar : EKCalendar?
    for cal in eventStore.calendars(for: EKEntityType.event) {
      if cal.title == "RushMe Frat Events" {
        calendar = cal
      }
    }
    if calendar == nil {
      calendar = EKCalendar(for: EKEntityType.event, eventStore: eventStore)
      calendar!.title = "RushMe Frat Events"
      if let source = eventStore.defaultCalendarForNewEvents?.source {
        calendar!.source = source
      }
      else {
       return (false, "No default calendar!")
      }
      calendar!.cgColor = COLOR_CONST.HIGHLIGHT_COLOR.cgColor
    }
    else {
      let predicate = eventStore.predicateForEvents(withStart:
                                  events.first!.startDate.addingTimeInterval(-86400*31),
                                                    end:
                                  events.last!.startDate.addingTimeInterval(86400*31),
                                                    calendars:
                                                      [calendar!])
      let calEvents = eventStore.events(matching: predicate)
      for event in calEvents {
        if event.calendar == calendar {
         let _ = try? eventStore.remove(event, span: EKSpan.thisEvent)
        }
      }
    }
    
    for event in events {
      let calEvent = EKEvent.init(eventStore: eventStore)
      calEvent.calendar = calendar
      calEvent.title = event.frat.name + "'s "  + event.name
      calEvent.startDate = event.startDate
      calEvent.endDate = event.endDate
      if let location = event.location {
        calEvent.structuredLocation = EKStructuredLocation.init(title: location)
      }
      do {
        try eventStore.save(calEvent, span: EKSpan.thisEvent)
        //print("Saved event " + calEvent.title + " at time "  +
        //        DateFormatter.localizedString(from: event.getStartDate(), dateStyle: .full, timeStyle: .full))
      } catch let e {
        print(e.localizedDescription)
      }
      
    }
    do {
      try eventStore.saveCalendar(calendar!, commit: true)
      try eventStore.commit()
      result = (true, "Successfully added " + String(events.count) + " events")
      //print("Successfully committed " + String(events.count) + " events to the calendar!")
    } catch let e {
      print(e.localizedDescription)
    }
    return result
  }
  */
  /*
   Saves a .ics file to the app's document directory, and
   returns the location at which the document was saved, if
   it was saved. If it was not saved, the URL will be nil!
   
   The exportAsICS function makes good use of the iCalKit
   open-source framework, a software bundle used to describe
   Apple's Date-type as .ics VEvents, all within a VCalendar.
   
   The function has two main components: firstly, it creates
   an ICS file, and secondly it saves that file to the disk.
 
 */
  static func exportAsICS(events : Set<FratEvent>) -> URL? {
    // Create the Array in which we will store the events
    var iCalEvents = [Event]()
    // Run through the FratEvents, add as much information
    // about each as possible.
    for event in events {
      var iCalEvent = Event()
      iCalEvent.dtstart = event.startDate
      iCalEvent.dtend = event.endDate
      iCalEvent.location = event.location
      iCalEvent.summary = event.name
      iCalEvents.append(iCalEvent)
    }
    // Compose a calendar, combining the events dynamically
    // into the VCalendar format.
    let calendar = Calendar(withComponents: iCalEvents)
    // The heavy-lifting is done here: translate the calendar
    // into its text-equivalent
    let iCalAsString = calendar.toCal()
    // Try(!) to find a place to save this file
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
     return nil
    }
    // Create the path, name the file "fratEvents.ics"
    let saveFileURL = path.appendingPathComponent("/fratEvents.ics")
    // Try(!) to save the file, handle all throws below
    do {
      try iCalAsString.write(to: saveFileURL, atomically: true, encoding: String.Encoding.ascii)
    }
    // If there are any errors, they are printed here
    catch let e {
      print(e.localizedDescription)
      return nil
    }
    // Success-- return where the file was saved.
    return saveFileURL
  }
  
  
}
    
    
    


