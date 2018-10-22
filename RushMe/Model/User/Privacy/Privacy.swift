//
//  Privacy.swift
//  RushMe
//
//  Created by Adam Kuniholm on 9/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation



struct Privacy {
  // When was the last time the user accepted or declined the Privacy Policy?
  static var lastPolicyInteractionDate : Date? {
    get {
      return userPreferencesCache.object(forKey: "privacyDate") as? Date
    }
    set {
      userPreferencesCache.set(Date(), forKey: "privacyDate")
    }
  }
  // Has the user accepted the Privacy Policy?
  static var policyAccepted : Bool {
    get {
      userPreferencesCache.set(Date(), forKey: "privacyDate")
      return !userPreferencesCache.bool(forKey: "privacyAccepted")
    }
    set {
      userPreferencesCache.set(!newValue, forKey: "privacyAccepted")
    }
  }
  // Has a new Privacy Polcy come out, or has the user never accepted one?
  static var preferencesNeedUpdating : Bool {
    get {
      if let lastDate = policyDate {
        return lastPolicyInteractionDate == nil || lastDate.compare(lastPolicyInteractionDate!) == .orderedDescending
      }
      else {
        return false 
      }
    }
  }
  // The most recent privacy policy pull:
  //          policy ---> "The RushMe Privacy Policy, last updated 09/08/2012. The..."
  //          publishDate --> (Date)09/08/2012
  //          mandatory --> true/false
  private static var privacyRow : Dictionary<String, Any?>?
  static var policy : String? {
    return privacyRow?["policy"] as? String ?? getPrivacyStatement()?.policy
  }
  static var policyDate : Date? {
    return privacyRow?["publishdate"] as? Date ?? getPrivacyStatement()?.effective
  }
  static var policyIsMandatory : Bool? {
    return privacyRow?["mandatory"] as? Bool ?? getPrivacyStatement()?.isMandatory
  }
  private static func getPrivacyStatement() -> (policy : String, effective: Date, isMandatory: Bool)? {
    guard let selectAttempt = try? Backend.selectAll(fromTable: "privacy.rushme").first,
      let dictionary = selectAttempt
    else {
      print("Failed to get the policy")
      return nil
    }
    
    guard let policy = dictionary["policy"] as? String,
      let dateString = dictionary["publishdate"] as? String,
      let isMandatoryRaw = dictionary["mandatory"] as? String, 
      let date = User.device.iso8601.date(from: dateString) else {
        print("Failed to initialize policy, publishdate, or mandatory")
        return nil
    }
    privacyRow = dictionary
    privacyRow!["publishdate"] = date
    return (policy, date, isMandatoryRaw == "true")
    
  }
}

fileprivate let userPreferencesCache : UserDefaults = {
  if let pDomain = UserDefaults.standard.persistentDomain(forName: "RushMe") {
    return UserDefaults.standard
  }
  else {
    UserDefaults.standard.setPersistentDomain([:], forName: "RushMe")
    return UserDefaults.standard 
  }
}()
