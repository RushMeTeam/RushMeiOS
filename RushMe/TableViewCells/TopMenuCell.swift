//
//  TopMenuCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

// Very simple top static cell of menu, presents icon image
// within a UIImageView, as well as the title of the app
// and a subheader with the makers of the app (RushMe and
// 4 1/2 Frat Boys, respectively)
// Only field is iconImageView to round icon corners
class TopMenuCell : UITableViewCell {
  // Presents app icon, configured in Main.storyboard
  @IBOutlet var iconImageView: UIImageView!
  // The equivalent of viewDidLoad() for UITableViewCells
  // Current adjustments made to icon image
  //        -- Round the corners
  override func layoutSubviews() {
    super.layoutSubviews()
    if let iView = iconImageView {
      // Mask to bounds so corners work
      iView.layer.masksToBounds = true
      iView.layer.cornerRadius = IMAGE_CONST.CORNER_RADIUS
    }
  }
}
