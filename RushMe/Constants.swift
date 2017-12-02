//
//  Constants.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

let DEBUG = false

// Images used often by the app
struct RMImage {
  static let NoImage = UIImage(named: "defaultImage.png")!
  static let IconImage = UIImage(named: "appIcon.png")!
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
  static let AppColor = UIColor(red: 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0, alpha: 1)
  static let NavigationItemsColor = AppColor
  static let SlideOutMenuShadowIsEnabled = false
  static let MenuButtonSelectedColor = UIColor.white.withAlphaComponent(0.5)
}
// Variables used to tune animations
struct RMAnimation {
  static let ColoringTime = 0.5
}
// Networking parameters, used to access the server
struct RMNetwork {
  static let userName = "guest"
  static let password = "guestaccess"
  static let databaseName = "fratinfo"
  static let IP = "34.225.179.240"
  static let HTTP = "http://" + IP + "/"
}

struct RMMessage {
  static let AppName = "RushMe"
  static let NoEvents = "No Events!"
  static let NoFavorites = "No Favorites!"
  static let LoadingFrats = "Wandering Campus, Looking for Frats..."
  static let Refresh = "Pull to Refresh!"
  static let Favorite = "Favorite"
  static let Unfavorite = "Unfavorite"
  static let Sharing = "Here are all the events I'll be going to this rush!"
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
  
}

struct RMPropertyKeys {
 static let FavoriteFraternities = "FavoriteFrats"
}
struct RMFileManagement {
  static let Path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let localURL = Path.appendingPathComponent("favoritedFrats")
}

struct RMDate {
  static let Today = Date.init(timeIntervalSince1970: 1505036460)
}
