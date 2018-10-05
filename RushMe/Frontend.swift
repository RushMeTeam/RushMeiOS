//
//  Design.swift
//  RushMe
//
//  Created by Adam Kuniholm on 9/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import Foundation

struct Frontend {
  
  struct images {
    static let noImage = UIImage(named: "defaultImage")!
    static let icon = UIImage(named: "appIcon")!
    static let logo = UIImage(named: "RushMeLogoInverted")!
    static let unfilledHeart = UIImage(named: "FavoritesUnfilled")
    static let filledHeart = UIImage(named: "FavoritesIcon")
  }
  
  struct text {
    static let appName = "RushMe"
    static let noEvents = "No events"
    static let noFavorites = "No Favorites!"
    static let loading = "Wandering Campus..."
    static let loadingFirstTime = "Setting up Campus for the first time..."
    static let refreshAgain = "Something went wrong. Pull to refresh!"
    static let favorite = "Favorite"
    static let unfavorite = "Unfavorite"
    static let shareMessage = "Here are all the events I'll be going to this rush!"
  }
  
  static let cornerRadius : CGFloat = 10
  
  struct colors {
    // RGB 41 171 226
    static let AppColor = UIColor(red: 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0, alpha: 1)
    static let NavigationItemsColor = AppColor
    static let SlideOutMenuShadowIsEnabled = true
    static let MenuButtonSelectedColor = UIColor.white.withAlphaComponent(0.15)
  } 
}

enum ShortCutIdentifier : String {
  case Fraternities
  case Maps
  case Calendar
  init?(identifier : String) {
    if let id = identifier.components(separatedBy: ".").last {
      self.init(rawValue: id)
    } else {
      return nil 
    }
  }
}


extension UIStoryboard {
  static var main : UIStoryboard {
    get {
      return UIStoryboard(name: "Main", bundle: nil) 
    }
  }
  static var privacy : UIStoryboard {
    get {
      return UIStoryboard(name: "FirstEntry", bundle: nil) 
    }
  }
}
