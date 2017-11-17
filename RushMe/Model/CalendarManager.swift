//
//  CalendarManager.swift
//  
//
//  Created by Adam Kuniholm on 11/11/17.
//

import UIKit
import EventKit
import iCalKit

fileprivate let eventStore = EKEventStore.init()

class CalendarManager: NSObject {

  
  static func export(events : [FratEvent], eventStore : EKEventStore) -> (succeeded : Bool, withDetails : String) {
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
      calendar!.cgColor = COLOR_CONST.MENU_COLOR.cgColor
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
  
  static func exportAsICS(events : [FratEvent]) -> URL? {
    var iCalEvents = [Event]()
    for event in events {
      var iCalEvent = Event()
      iCalEvent.dtstart = event.startDate
      iCalEvent.dtend = event.endDate
      iCalEvent.location = event.location
      iCalEvent.summary = event.name
      iCalEvents.append(iCalEvent)
    }
    let calendar = Calendar(withComponents: iCalEvents)
    let iCalAsString = calendar.toCal()
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
     return nil
    }
    let saveFileURL = path.appendingPathComponent("/fratEvents.ics")
    do {
      try iCalAsString.write(to: saveFileURL, atomically: true, encoding: String.Encoding.ascii)
    }
    catch let e {
     print(e)
    }
    return saveFileURL
  }
  
  
}
    
    
    


