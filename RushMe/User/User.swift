//
//  User.swift
//  RushMe
//
//  Created by Adam Kuniholm on 9/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import DeviceKit

// User preferences
struct User {
  struct session {
    private static var subscribedEventsKey = "subscribedEvents"
    private static var favoriteFraternityKey = "favoriteFraternities"
    
    static var selectedEvents : Set<Fraternity.Event> {
      get {
        let eventHashes = Set<Int>(userPreferencesCache.array(forKey: subscribedEventsKey) as? [Int] ?? [])
        return RushCalendar.shared.events.filter({ (event) -> Bool in
          return eventHashes.contains(event.hashValue)
        })
      }
      set {
        let alteredEvents = selectedEvents.symmetricDifference(newValue)
        for event in alteredEvents {
          Backend.log(action: !event.isSubscribed ? Action.Subscribed(event: event) : Action.Unsubscribed(event: event))
        }
        userPreferencesCache.set(Array<Int>(newValue.map({ (event) -> Int in
          return event.hashValue
        })), forKey: subscribedEventsKey)
        Notifications.refresh()
      }
    }
    
    static var favoriteFrats : Set<Fraternity> {
      get {
        let fratHashes = Set<Int>(userPreferencesCache.array(forKey: favoriteFraternityKey) as? [Int] ?? [])
        return Set<Fraternity>(Campus.shared.fraternitiesByKey.values.filter({ (frat) -> Bool in
          return fratHashes.contains(frat.hashValue)
        }))
      }
      set {
        let alteredFrats = favoriteFrats.symmetricDifference(newValue)
        for frat in alteredFrats where Campus.shared.fraternityNames.contains(frat.name) {
          Backend.log(action: favoriteFrats.contains(frat) ? Action.Unfavorited(fraternity: frat) : Action.Favorited(fraternity: frat))
        }
        userPreferencesCache.set(Array<Int>(newValue.map({ (frat) -> Int in
          return frat.hashValue
        })), forKey: favoriteFraternityKey)
        Notifications.refresh()
        
      }
    }
    
  }
  
  struct preferences {
    static private var displayFavoritesOnly_ : Bool? = nil
    static var displayFavoritesOnly : Bool {
      get {
        return displayFavoritesOnly_ ?? false
      } set {
        displayFavoritesOnly_ = newValue
      }
    }
    // Include events that have already occured on the calendar?
    // Default: true
    static var considerPastEvents : Bool {
      get {
        return userPreferencesCache.bool(forKey: "considerPastEvents")
      }
      set {
        userPreferencesCache.set(newValue, forKey: "considerPastEvents")
      }
    }
    // Fraternities are listed in random order? 
    // Default: true
    static var shuffleEnabled : Bool {
      get {
        return !userPreferencesCache.bool(forKey: "shuffleEnabled")
      }
      set {
        userPreferencesCache.set(!newValue, forKey: "shuffleEnabled")
      }
    }
    // The user has accepted the privacy policy?
    // Default: false
    static var privacyPolicyAccepted : Bool {
      get {
        return Privacy.policyAccepted
      }
      set {
        Privacy.policyAccepted = newValue
      }
    }
  }
  struct device {
    // Date formatter should be moved to a "formatter" struct
    private static var dateFormatter : DateFormatter {
      get {
        let dF = DateFormatter()
        dF.isLenient = true
        dF.dateFormat = "yyyy-MM-dd HH:mm:ss.ZZZZ"
        return dF
      }
    }
    static var properties : Dictionary<String, Any> {
      get {
        return ["duuid" : UIDevice.current.identifierForVendor?.uuidString as Any,
                "rtime" : Format.dates.SQLDateFormatter.string(from: Date()),
                "dtype" : DeviceKit.Device().description,
                "dsoft" : UIDevice.current.systemVersion,
                "appv" : User.device.appVersion]
      }
    }
    static let iso8601: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime]
      return formatter
    }()
    fileprivate static let appVersion =
      ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "") +
        "-" +
        ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "")
    
  }
  struct files {
    static let Path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let favoritedFratURL = Path.appendingPathComponent("favoritedFrats")
    static let userActionsURL = Path.appendingPathComponent("userActions")
    static let userInfoURL = Path.appendingPathComponent("userInfo")
    static let fratImageURL = Path.appendingPathComponent("images")
    static let locationsURL = Path.appendingPathComponent("locations")
  }
  
  class debug {
    
    static var isEnabled : Bool {
      get {
        return userPreferencesCache.bool(forKey: "debugEnabled")
      }
    }
    @objc private static func isEnabledToggle(recognizer : UIGestureRecognizer) {
      guard recognizer.state == .began else {
        return 
      }
      if (!isEnabled) {
        promptUser() 
      } else {
        toggleEnabledState()
      }
    }
    private static var confirmationVC : UIAlertController { 
      get {
        let vc = UIAlertController.init(title: "Debug RushMe?", message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction.init(title: "Sure", style: .destructive, handler: { (action) in
          toggleEnabledState()
        }))
        vc.addAction(UIAlertAction.init(title: "What? No!", style: .cancel, handler: nil))
        return vc
      }
    }
    private static var okayVC : UIAlertController { 
      get {
        let vc = UIAlertController(title: "Debugging \(isEnabled ? "en" : "dis")abled!", message: "Please restart RushMe.", preferredStyle: .alert)
        vc.addAction(UIAlertAction.init(title: "Thanks dude!", style: .default, handler: nil))
        return vc
      }
    }
    
    private static func confirmWithUser() {
      UIApplication.shared.keyWindow?.rootViewController?.present(okayVC, animated: true, completion: nil)
    }
    private static func promptUser() {
      UIApplication.shared.keyWindow?.rootViewController?.present(confirmationVC, animated: true, completion: nil) 
    }
    static func toggleEnabledState() {
      print("Debugging \(isEnabled ? "dis" : "en")abled!")
      userPreferencesCache.set(!isEnabled, forKey: "debugEnabled")
      confirmWithUser()
    }
    static let defaultDate : Date = DateComponents(calendar: .autoupdatingCurrent,
                                                   year: 2018, 
                                                   month: 10, 
                                                   day: 19, 
                                                   hour: 9, 
                                                   minute: 30).date! 
    static var debugDate : Date? {
      get {
        guard isEnabled else {
         return nil 
        }
        guard let dateString = userPreferencesCache.string(forKey: "debugDateToday"),
          let date = Format.dates.SQLDateFormatter.date(from: dateString) else {
            return DateComponents(calendar: .autoupdatingCurrent,year: 2018, month: 10, day: 19, hour: 9, minute: 30).date! 
        }
        return date
      } 
      set {
        guard isEnabled else {
          return
        }
        if let date = newValue  {
          let dateString = Format.dates.SQLDateFormatter.string(from: date)
          userPreferencesCache.set(dateString, forKey: "debugDateToday")
        } else {
          userPreferencesCache.set("", forKey: "debugDateToday")  
        }
      }
    }
    
    static var enableDebugGestureRecognizer : UIGestureRecognizer {
      get {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 3
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(isEnabledToggle))
        return recognizer
      }
      
    }
  }
  
}

// Cache user preferences
fileprivate let userPreferencesCache : UserDefaults = {
  if let pDomain = UserDefaults.standard.persistentDomain(forName: "RushMe") {
    return UserDefaults.standard
  }
  else {
    UserDefaults.standard.setPersistentDomain([:], forName: "RushMe")
    return UserDefaults.standard 
  }
}()
