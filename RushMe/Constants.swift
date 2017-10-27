//
//  Constants.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

struct IMAGE_CONST {
  static let NO_IMAGE = UIImage(named: "defaultImage.png")!
  static let ICON_IMAGE = UIImage(named: "appIcon.png")!
  static let CORNER_RADIUS : CGFloat = 8
}

struct COLOR_CONST {
  static let MENU_COLOR = UIColor(red: 41.0/255.0, green: 171.0/255.0, blue: 226.0/255.0, alpha: 1)
  static let NAVIGATION_BAR_COLOR = MENU_COLOR
  static let SLIDEOUT_MENU_SHADOW_ENABLED = false
  static let MENU_BUTTON_SELECTED_COLOR = UIColor.white.withAlphaComponent(0.5)
}

struct ANIM_CONST {
  static let COLORING_TIME = 0.5
}
