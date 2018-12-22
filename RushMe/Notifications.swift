//
//  Notifications.swift
//  RushMe
//
//  Created by Adam on 12/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UserNotifications



class Notifications {
  enum Trigger : String {
    case Push = "pushRequest"
    case Scheduled  = "dailyAggregateRequest"
    case Reminder = "reminderRequest"
    case Location = "locationRequest"
  }
  
  static func update(selected types : [Trigger] = [.Scheduled, .Reminder]) {
    
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      switch settings.authorizationStatus {
        
      case .notDetermined:
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler: { (blocked, error) in
          if let _ = error {
            print("Notifications/Authorization/Error: \(error)") 
          }
        })
        return
      case .denied:
        print("Notifications/Error/UserDeniedNotifications")
        return
      case .authorized:
        forceUpdate(selected: types)
        return
      case .provisional:
        forceUpdate(selected: types)
        return
      }
    } 
  }
  
  private static func forceUpdate(selected types : [Trigger]) {
    
    let typeStrings = Set<String>(types.map({ (trigger) -> String in
      return trigger.rawValue
    }))
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: Array<String>(typeStrings))
    let now = Date()
    
    if types.contains(.Scheduled) {
      addDailyNotifications(for: eventsByDay(withFilter: { (event) -> Bool in
        return event.frat.isFavorite && event.ending > now
      }))
    }
    if types.contains(.Reminder) {
      addReminderNotifications(for: eventsByDay(withFilter: { (event) -> Bool in
        return event.isSubscribed && event.ending > now && RushCalendar.shared.eventsOn(now)?.contains(event) ?? false
      }))
    }
  }
  
  
  private static func addReminderNotifications(for daysEvents : Dictionary<Date, Set<Fraternity.Event>>) {
    for events in daysEvents.values {
      for event in events  {
        let content = UNMutableNotificationContent()
        content.title = "Hello! A rush event is coming up soon!"
        content.subtitle = "\(event.name) at \(event.frat.name) starts in \(15) minutes!"
        content.badge = 1
        
        let mins = -20.0
        let interval = TimeInterval(mins*60)
        let date = event.ending.addingTimeInterval(interval)
        
        let triggerDateComponents = DateComponents(year: date.year, month: date.month, 
                                                   day: date.day, hour: date.hour, minute: date.minute)  
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: Trigger.Reminder.rawValue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
          print("Notifications/Adding/Error: \(error?.localizedDescription ?? "None")")
        
        }
      }
    } 
  }
  
  
  private static func addDailyNotifications(for daysEvents : Dictionary<Date, Set<Fraternity.Event>>) {
    // Add single notification with day's descriptions
    for (day, events) in daysEvents where !events.isEmpty {
      
      // Happy Rush! 20 events are happening accross campus.
      // Bowling with Alpha Phi Alpha is up next, as well as
      // 5 more followed events
      let firstEvent = events.sorted(by: <).first!
      guard firstEvent.starting > Date() else {
       continue 
      }
      let content = UNMutableNotificationContent()
      content.title = "Happy Rush! \(events.count) event\(events.count == 1 ? " is" : "s are") today, all accross campus!"
      content.body = "\(firstEvent.name) with \(firstEvent.frat.name) is up next"
      content.body += events.count == 1 ? "." : ", in addition to \(events.count-1) more followed events."
      content.badge = 1
      
      let triggerDateComponents = DateComponents(year: day.year, month: day.month, day: day.day, hour: 10)  
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
      
      let request = UNNotificationRequest(identifier: Trigger.Scheduled.rawValue, content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { (error) in
        print("Notifications/Adding/Error: \(error?.localizedDescription ?? "None")")
      }
    } 
  }
  private static func eventsByDay(withFilter eventFilter : (Fraternity.Event) -> Bool) -> Dictionary<Date, Set<Fraternity.Event>> {
    var daysEvents = Dictionary<Date, Set<Fraternity.Event>>()
    for (day, events) in RushCalendar.shared.eventsByDay {
      daysEvents[day] = events.filter(eventFilter)
    }
    return daysEvents
  }

}
