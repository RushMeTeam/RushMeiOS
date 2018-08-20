//
//  Constants.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import DeviceKit
import CoreLocation.CLLocation


let DEBUG = false
fileprivate let defaults : UserDefaults = {
  if let pDomain = UserDefaults.standard.persistentDomain(forName: "RushMe") {
   return UserDefaults.standard
  }
  else {
    UserDefaults.standard.setPersistentDomain([:], forName: "RushMe")
   return UserDefaults.standard 
  }
}()

// Images used often by the app

// Filename extensions for photos stored on the server
struct RMImageQuality {
  static let High = ""
  static let Medium = "_Half.png.png"
  static let Low = "_Quarter.png.png"
}
// Colors and variables used in the presentation of the app
struct RMColor {
  // RGB 41 171 226
  static let AppColor = UIColor(red: 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0, alpha: 1)
  static let NavigationItemsColor = AppColor
  static let SlideOutMenuShadowIsEnabled = true
  static let MenuButtonSelectedColor = UIColor.white.withAlphaComponent(0.15)
}
// Variables used to tune animations
struct RMAnimation {
  static let ColoringTime = 0.5
}
// Networking parameters, used to access the server


struct RMMessage {
  static let AppName = "RushMe"
  static let NoEvents = "No events"
  static let NoFavorites = "No Favorites!"
  static let LoadingFrats = "Wandering Campus..."
  static let LoadingFratsFirstTime = "Setting up Campus for the first time..."
  static let Refresh = "Something went wrong. Pull to refresh!"
  static let Favorite = "Favorite"
  static let Unfavorite = "Unfavorite"
  static let Sharing = "Here are all the events I'll be going to this rush!"
}
//struct RMFratPropertyKeys {
// static let fratMapAnnotation = "Annotation"
//}

struct RMDatabaseFormat {
  private static var dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
  static var dateFormatter : DateFormatter {
    get {
      let formatter = DateFormatter()
      formatter.dateFormat = dateFormat
      return formatter
    }
  }
  static func date(fromSQLDateTime inputString: String) -> Date? {
    return self.dateFormatter.date(from: inputString)
  }
}


// TODO: Make user preferences save (should include display events before today!)
struct RushMe {
  static let dateFormatter : DateFormatter = {
    let dF = DateFormatter()
    dF.isLenient = true
    dF.dateFormat =  "MM/dd/yyyy"
    dF.formatterBehavior = .default
    dF.locale = Locale.current
    return dF
  }()
  static let dateTimeFormatter : DateFormatter = {
    let dTF = DateFormatter()
    dTF.dateFormat = "MM/dd/yyyy hh:mm"
    dTF.isLenient = true
    dTF.locale = Locale.current
    dTF.formatterBehavior = .default
    return dTF
  }()
  static let defaultSQLDateFormatter : DateFormatter = {
    let dF = DateFormatter()
    dF.isLenient = true
    dF.dateFormat = "yyyy-MM-dd"
    dF.formatterBehavior = .default
    dF.locale = Locale.current
    return dF
  }()
  static var considerPastEvents : Bool {
    get {
      return !defaults.bool(forKey: "considerPastEvents")
    }
    set {
      defaults.set(!newValue, forKey: "considerPastEvents")
    }
  }
  static var shuffleEnabled : Bool {
    get {
      return !defaults.bool(forKey: "shuffleEnabled")
    }
    set {
      defaults.set(!newValue, forKey: "shuffleEnabled")
    }
  }
  struct privacy {
    static var lastPolicyInteractionDate : Date? {
      get {
        return defaults.object(forKey: "privacyDate") as? Date
      }
      set {
        defaults.set(Date(), forKey: "privacyDate")
      }
    }
    static var policyAccepted : Bool {
      get {
        defaults.set(Date(), forKey: "privacyDate")
        return !defaults.bool(forKey: "privacyAccepted")
      }
      set {
        defaults.set(!newValue, forKey: "privacyAccepted")
      }
    }
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
      if let dictionary = SQLHandler.selectAll(fromTable: "privacy")?.first,
        let policy = dictionary["policy"] as? String,
        let dateString = dictionary["publishdate"] as? String,
        let isMandatoryRaw = dictionary["mandatory"] as? String, 
        let date = RushMe.defaultSQLDateFormatter.date(from: dateString) {
        privacyRow = dictionary
        privacyRow!["publishdate"] = date
        return (policy, date, isMandatoryRaw == "1")
      }
      return nil
    }
    
    
  }
  struct network {
    static let userName = "RushMePublic"
    static let password = "fras@a&etHaS#7eyudrum+Hak?fresax"
    static let databaseName = "fratinfo"
    static let userActionsTableName = "sqlrequests"
    static let web = URL(string: "http://ec2-18-188-8-243.us-east-2.compute.amazonaws.com/request.php")!
    static let S3 = URL(string: "https://s3.us-east-2.amazonaws.com/rushmepublic/")!
  }
  struct keys {
    struct database {
      static let fraternities = "house_info"
      static let events = "events"
    }
    struct frat {
      static let name = "name"
      static let chapter = "chapter"
      static let memberCount = "members"
      static let description = "description"
      static let gpa = "gpa"
      static let address = "address"
      static let previewImage = "preview_image"
      static let profileImage = "profile_image"
      static let coverImage = "cover_image"
      static let calendarImage = "calendar_image"
    }
  }
  struct campus {
   static let coordinates = CLLocationCoordinate2D(latitude: 42.729305, longitude: -73.677647)
  }
  struct images {
    static let none = UIImage(named: "defaultImage")!
    static let icon = UIImage(named: "appIcon")!
    static let logo = UIImage(named: "RushMeLogoInverted")!
    static let unfilledHeart = UIImage(named: "FavoritesUnfilled")
    static let filledHeart = UIImage(named: "FavoritesIcon")
  }
  static let cornerRadius : CGFloat = 10
}


struct RMPropertyKeys {
  static let FavoriteFraternities = "FavoriteFrats"
  static let ConsiderEventsBeforeTodayKey = "ConsiderEventsBeforeToday"
  
}
struct RMFileManagement {
  static let Path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let favoritedFratURL = Path.appendingPathComponent("favoritedFrats")
  static let userActionsURL = Path.appendingPathComponent("userActions")
  static let userInfoURL = Path.appendingPathComponent("userInfo")
  static let fratImageURL = Path.appendingPathComponent("images")
  static let locationsURL = Path.appendingPathComponent("locations")
}

struct RMDate {
  static let Today = Date.init(timeIntervalSince1970: 1505036460)
}

struct RMUserDevice {
  static var dateFormatter : DateFormatter {
    get {
      let dF = DateFormatter()
      dF.isLenient = true
      dF.dateFormat = "yyyy-MM-dd HH:mm:ss.ZZZZ"
      return dF
    }
  }
  var deviceInfo : Dictionary<String, Any> {
    get {
      return ["duuid" : UIDevice.current.identifierForVendor?.uuidString as Any,
              "rtime" : RMDatabaseFormat.dateFormatter.string(from: Date()),
              "dtype" : Device().description,
              "dsoft" : UIDevice.current.systemVersion,
              "appv" : RMUserDevice.appVersion]
    }
  }
  fileprivate static let appVersion =
    ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "") +
      "-" +
      ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "")
  
}







