//
//  Notifications.swift
//  RushMe
//
//  Created by Adam on 12/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UserNotifications



class Notifications : NSObject {
  enum Trigger : String, CaseIterable {
    case Push = "pushRequest"
    case Scheduled  = "dailyAggregateRequest"
    case Reminder = "reminderRequest"
    case Location = "locationRequest"
  }
  
  static func refresh(selected types : [Trigger] = [.Scheduled, .Reminder], requestAuthorization : Bool = true) {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      guard settings.authorizationStatus == .authorized ||
        (settings.authorizationStatus == .notDetermined && requestAuthorization) else {
          return
      }
      removePendingNotifications()
      update(selected: types)
    }
  }
  
  private static func update(selected types : [Trigger]) {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge],
      completionHandler: { (authorized, error) in
        guard error == nil, authorized else  {
          print("Notifications/Authorization/Error: \(error?.localizedDescription ?? "None"))")
          print("\tAuthorization: \(authorized ? "yes"  : "blocked")")
          return
        }
        forceUpdate(selected: types)
    })
  }
  private static var now = User.debug.debugDate ?? Date()
  
  private static func isValidDailyEvent(event : Fraternity.Event) -> Bool {
    return event.frat.isFavorite && event.ending > now
  }
  private static func isValidReminderEvent(event : Fraternity.Event) -> Bool {
    return event.ending > now
  }
  
  private static func forceUpdate(selected types : [Trigger]) {
    for type in Set<Trigger>(types) {
      switch type {
      case .Scheduled:
        addDailyNotifications(for: eventsByDay(withFilter: isValidDailyEvent))
      case .Reminder:
        addReminderNotifications(for: eventsByDay(withFilter: isValidReminderEvent))
      default:
        print("Notifications/Update: Unimplemented type requested...")
//      case .Push:
//      case .Location:
      }
    }
  }
  
  private static func removePendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
      //print("Notifications/PrintPending: \(requests.count) pending notification request\(requests.count == 1 ? "" : "s")")
      var outStr = ""
      for type in Trigger.allCases {
        let count = requests.filter({ (request) -> Bool in
          return request.identifier.contains(type.rawValue)
        }).count
        outStr += " \(count) \(type)\(type == Trigger.allCases.last! ? "" : ",")"
      }
      //print(outStr)
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
  }
  private static func addReminderNotifications(for eventsByDay : Dictionary<Date, Set<Fraternity.Event>>) {
    var notificationsByDay = Dictionary<DateComponents, UNNotificationRequest>()
    for (_, events) in eventsByDay {
      for event in events  {
        let content = UNMutableNotificationContent()
        content.title = "\(event.frat.name) is having an event!"
        content.body = "\(event.name) starts at \(event.starting.hour)."
        content.body += " Head over to \(event.location ?? event.frat.name) to learn more."
        
        var triggerDate = event.starting
        // add the difference between event date and debug date to current date
        // triggerDate = (debugDate - eventDate) + currentDate
        
        if let debugDate = User.debug.debugDate {
          let diff = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: debugDate, to: triggerDate)
          triggerDate = Calendar.current.date(byAdding: diff, to: Date(), wrappingComponents: false)!
        }
        
        let triggerDateComponents = DateComponents(year: triggerDate.year, month: triggerDate.month,
                                                   day:  triggerDate.day,  hour: triggerDate.hour,
                                                   minute: max(triggerDate.minute - 15, 0))
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: Trigger.Reminder.rawValue + "-" + event.name, content: content, trigger: trigger)
        if let _ = notificationsByDay[triggerDateComponents] {
          
        } else {
         notificationsByDay[triggerDateComponents] = request
        }
      }
    }
    notificationsByDay.values.forEach { (request) in
      UNUserNotificationCenter.current().add(request) { (error) in
        if let description = error?.localizedDescription {
          print("Notifications/AddReminder/Error: \(description)")
//          print("\t\t\tTrigger DateComponents: \(String(describing: triggerDateComponents))")
        }
      }
    }
    
  }
  
  
  private static func addDailyNotifications(for eventsByDay : Dictionary<Date, Set<Fraternity.Event>>) {
    // Add single notification with day's descriptions
    
    for (day, events) in eventsByDay where !events.isEmpty {
      // Happy Rush! 20 events are happening accross campus.
      // Bowling with Alpha Phi Alpha is up next, as well as
      // 5 more followed events
      
      let firstEvent = events.sorted(by: <).first!
      let content = UNMutableNotificationContent()
      content.title = "Happy Rush! \(events.count) event\(events.count == 1 ? " is" : "s are") today, all accross campus!"
      content.body = "\(firstEvent.name) with \(firstEvent.frat.name) is up next"
      content.body += events.count == 1 ? "." : ", in addition to \(events.count-1) more followed events."
      
      var triggerDate = day
      if let debugDate = User.debug.debugDate {
        // triggerDate = (debugDate - eventDate) + currentDate
        let diff = Calendar.current.dateComponents([.day, .month, .year], from: debugDate, to: triggerDate)
        triggerDate = Calendar.current.date(byAdding: diff, to: Date(), wrappingComponents: false)!
      }
      
      let triggerDateComponents = DateComponents(year: triggerDate.year, month: triggerDate.month,
                                                 day: triggerDate.day,   hour: 10)
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
      let request = UNNotificationRequest(identifier: Trigger.Scheduled.rawValue + " " + String(describing: day), content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { (error) in
        if let description = error?.localizedDescription {
          print("Notifications/AddDaily/Error: \(description)")
          print("\t\t\tTrigger DateComponents: \(String(describing: triggerDateComponents))")
        }
      }
    }
  }
  private static func eventsByDay(withFilter eventFilter : (Fraternity.Event) -> Bool) -> Dictionary<Date, Set<Fraternity.Event>> {
    var daysEvents = Dictionary<Date, Set<Fraternity.Event>>()
    User.session.selectedEvents.filter(eventFilter).forEach { (event) in
      if (!daysEvents.keys.contains(event.starting.dayDate)) {
        daysEvents[event.starting.dayDate] = Set<Fraternity.Event>()
      }
      daysEvents[event.starting.dayDate]!.insert(event)
    }
    return daysEvents
  }
  
}

extension Notifications : UNUserNotificationCenterDelegate {
  // MARK: UNUserNotificationCenterDelegate
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print(response.notification.request.content.body)
    completionHandler()
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print(notification.request.content.body)
    completionHandler([.alert])
  }
  //  func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {}
}


