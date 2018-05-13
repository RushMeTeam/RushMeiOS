//
//  Constants.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

//import Foundation
import UIKit
import DeviceKit

let DEBUG = false

// Images used often by the app
struct RMImage {
  static let NoImage = UIImage(named: "defaultImage")!
  static let IconImage = UIImage(named: "appIcon")!
  static let LogoImage = UIImage(named: "RushMeLogoInverted")!
  static let FavoritesImageUnfilled = UIImage(named: "FavoritesUnfilled")
  static let FavoritesImageFilled = UIImage(named: "FavoritesIcon")
  static let CornerRadius : CGFloat = 8
}
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
  static let SlideOutMenuShadowIsEnabled = false
  static let MenuButtonSelectedColor = UIColor.white.withAlphaComponent(0.15)
}
// Variables used to tune animations
struct RMAnimation {
  static let ColoringTime = 0.5
}
// Networking parameters, used to access the server
struct RMNetwork {
  static let userName = "RushMePublic"
  static let password = "fras@a&etHaS#7eyudrum+Hak?fresax"
  static let databaseName = "fratinfo"
  static let userActionsTableName = "sqlrequests"
  static let web = URL.init(string: "http://ec2-18-188-8-243.us-east-2.compute.amazonaws.com/request.php")!
  static let S3 = URL.init(string: "https://s3.us-east-2.amazonaws.com/rushmepublic/")!
}

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
struct RMFratPropertyKeys {
 static let fratMapAnnotation = "Annotation"
}

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

struct RMDatabaseKey {
  static let NameKey = "name"
  static let ChapterKey = "chapter"
  static let MemberCountKey = "members"
  static let DescriptionKey = "description"
  static let gpaKey = "gpa"
  static let AddressKey = "address"
  static let PreviewImageKey = "preview_image"
  static let ProfileImageKey = "profile_image"
  static let CoverImageKey = "cover_image"
  static let CalendarImageKey = "calendar_image"
  static let FraternityInfoRelation = "house_info"
  static let EventInfoRelation = "events"
}
struct RMUser {
  static let minPassLength = 6 
  static let minUsernameLength = 6
}
// TODO: Make user preferences save (should include display events before today!)
struct RMUserPreferences {
  static private var shuffleEnabled_ : Bool? = nil
  static private var shuffleEnabledDefault = true
  static var shuffleEnabled : Bool = shuffleEnabledDefault
  
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
     let dF = DateFormatter.init()
      dF.dateFormat = "yyyy-MM-dd HH:mm:ss.ZZZZ"
      return dF
    }
  }
  var deviceInfo : Dictionary<String, Any> {
    get {
      return ["duuid" : (UIDevice.current.identifierForVendor?.uuidString ?? "ID Broken"),
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






