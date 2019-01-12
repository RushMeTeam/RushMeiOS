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
      removeAllNotifications()
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
        add(notificationsFor: User.session.selectedEvents.filter(isValidDailyEvent), grouping: [.day, .month, .year])
//        addDailyNotifications(for: eventsByDay(withFilter: isValidDailyEvent))
      case .Reminder:
        add(notificationsFor: User.session.selectedEvents.filter(isValidReminderEvent), grouping: [.day, .month, .year, .hour])
//        addReminderNotifications(for: eventsByDay(withFilter: isValidReminderEvent))
      default:
        print("Notifications/Update: Unimplemented type requested...")
//      case .Push:
//      case .Location:
      }
    }
  }
  
  private static func removeAllNotifications() {
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
      DispatchQueue.main.async {
        UIApplication.shared.applicationIconBadgeNumber = 0
      }
      
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
  }
  private static func addReminderNotifications(for eventsByDay : Dictionary<Date, Set<Fraternity.Event>>) {
    var notificationsByDay = Dictionary<DateComponents, UNNotificationRequest>()
    for (_, events) in eventsByDay {
      for event in events  {
        let content = UNMutableNotificationContent()
        content.title = "\(event.frat.name) is having an event!"
        if let hour = event.starting.components.hour {
          content.body = "\(event.name) starts at \(hour). "
        }
        content.body += "Head over to \(event.location ?? event.frat.name) to learn more."
        
        var eventDate = event.starting

        if let debugDate = User.debug.debugDate {
          // add the difference between event date and debug date to current date
          // triggerDate = (debugDate - eventDate) + currentDate
          let diff = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: debugDate, to: eventDate)
          eventDate = Calendar.current.date(byAdding: diff, to: Date(), wrappingComponents: false)!
        }
        
        let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute], from: eventDate)
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
        }
      }
    }
  }
  
  private static func add(notificationsFor events : Set<Fraternity.Event>, grouping : Set<Calendar.Component>) {
    var triggers = Set<UNCalendarNotificationTrigger>()
    events.forEach { (event) in
      let components = Calendar.autoupdatingCurrent.dateComponents(grouping, from: event.starting)
      triggers.insert(UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
    }
    
    var remainingEvents = events
    var requests = [UNNotificationRequest]()
    
    for trigger in triggers {
      let triggeredEvents = remainingEvents.filter { (event) -> Bool in
        let components = Calendar.autoupdatingCurrent.dateComponents(grouping, from: event.starting)
        return trigger.dateComponents == components
      }.sorted(by: <)
      let fraternities = triggeredEvents.map { (event) -> Fraternity in
        return event.frat
      }
      guard let firstEvent = triggeredEvents.first else {
        print("No first event!")
       continue 
      }
      let content = UNMutableNotificationContent()

      switch fraternities.count {
      case 0 :
        print("Error! No Events Today!")
        break
      case 1:
        // Chi Phi has an event soon!
        // Alpha Chi Rho has events today!
        content.title = "\(fraternities[0].name) has \(triggeredEvents.count > 1 ? "events" : "an event") \(grouping.contains(.hour) ? "soon" : "today")!"
      case 2:
        // Chi Phi and Alpha Chi Rho have events soon!
        // Chi Phi and Alpha Chi Rho have events today!
        content.title = "\(fraternities[0].name) and \(fraternities[1].name) have events \(grouping.contains(.hour) ? "soon" : "today")!"
      case 3:
        // Chi Phi, Alpha Chi Rho, and Pi Kappa Alpha have events soon!
        // Chi Phi, Alpha Chi Rho, and Pi Kappa Alpha have events today!
        content.title = "\(fraternities[0].name), \(fraternities[1].name), and \(fraternities[2].name) have events \(grouping.contains(.hour) ? "soon" : "today")!"
      default:
        // Chi Phi, Alpha Chi Rho, and 5 others have events soon!
        // Chi Phi, Alpha Chi Rho, and 5 others have events today!
        content.title = "\(fraternities[0].name), \(fraternities[1].name), and \(fraternities.count - 2) others have events \(grouping.contains(.hour) ? "soon" : "today")!"
      }

      // Chi Phi's event, Casino Night, starts at 10 AM. Head to Freshman Circle to learn more.
      if let hour = triggeredEvents.first?.starting.components.hour {
        let hourString = "\(hour > 12 ? hour - 12 : hour) \(hour >= 12 ? "PM" : "AM")"
        content.body = "\(firstEvent.frat.name)'s event, \(firstEvent.name), starts at \(hourString). "
        if let location = firstEvent.location {
          content.body += "Head to \(location) to learn more!"
        } else if let location = firstEvent.frat.address {
          content.body += "Head to the \(firstEvent.frat.name.greekLetters) house, \(location), to learn more!"
        }
      } else {
       content.body = "Tap to learn more!" 
      }
      
      var requestTrigger = trigger
      if let debugDate = User.debug.debugDate {
        // add the difference between event date and debug date to current date
        // triggerDate = (debugDate - eventDate) + currentDate
        let eventDate = Calendar.current.date(from: trigger.dateComponents)!
        let diff = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: debugDate, to: eventDate)
        let triggerDate = Calendar.current.date(byAdding: diff, to: Date(), wrappingComponents: false)!
        let triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents(grouping, from: triggerDate)
        requestTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
      } 
      
      let request = UNNotificationRequest(identifier: Trigger.Scheduled.rawValue + " " + String(describing: trigger.dateComponents), 
                                          content: content, 
                                          trigger: requestTrigger)
      requests.append(request)
      remainingEvents.subtract(triggeredEvents)
    }
    
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge],
      completionHandler: { (authorized, error) in
        guard error == nil, authorized else  {
          print("Notifications/Authorization/Error: \(error?.localizedDescription ?? "None"))")
          print("\tAuthorization: \(authorized ? "yes"  : "blocked")")
          return
        }
        for request in requests {
          UNUserNotificationCenter.current().add(request) { (error) in
            if let description = error?.localizedDescription {
              print("Notifications/Add/Error: \(description)")
              print("\t\t\tTrigger DateComponents: \(request.trigger.debugDescription)")
            }
          }
        }
    })
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
      
      var triggerDateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: triggerDate)
      triggerDateComponents.hour = 10

      
      let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
      let request = UNNotificationRequest(identifier: Trigger.Scheduled.rawValue + " " + String(describing: trigger.dateComponents), content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { (error) in
        if let description = error?.localizedDescription {
          print("Notifications/AddDaily/Error: \(description)")
          print("\t\t\tTrigger DateComponents: \(String(describing: trigger.dateComponents))")
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


