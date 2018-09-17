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
  struct preferences {
    // Include events that have already occured on the calendar?
    // Default: true
    static var considerPastEvents : Bool {
      get {
        return !userPreferencesCache.bool(forKey: "considerPastEvents")
      }
      set {
        userPreferencesCache.set(!newValue, forKey: "considerPastEvents")
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
                "dtype" : Device().description,
                "dsoft" : UIDevice.current.systemVersion,
                "appv" : User.device.appVersion]
      }
    }
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
