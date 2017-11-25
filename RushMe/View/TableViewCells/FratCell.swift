//
//  FratCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

// A subclass UITableViewCell that represents a fraternity
// Fields:
//      -- A title label that presents the national fraternity's name
//      -- A preview image view which shows a preview photo
//                  -- By default, it is IMAGE_CONST.NO_IMAGE
//      -- A subheading label that presents the chapter's name
class FratCell : UITableViewCell {
  // Fraternity name (e.g. Alpha Beta Gamma)
  @IBOutlet var titleLabel: UILabel!
  // Preview image (e.g. a crest)
  @IBOutlet var previewImageView: UIImageView!
  // Chapter designation (e.g. Theta)
  @IBOutlet var subheadingLabel: UILabel!
  // The equivalent of viewDidLoad() for UITableViewCells
  // Current adjustments made to preview image
  //        -- Round the corners
  override func layoutSubviews() {
    super.layoutSubviews()
    // Mask to bounds so corners work
    if let iView = previewImageView {
      iView.layer.masksToBounds = true
      iView.layer.cornerRadius = RMImage.CornerRadius
      iView.contentMode = UIViewContentMode.scaleAspectFill
      // If there is no preview image
      if (iView.image == nil){
        iView.image = RMImage.NoImage
      }
    }
  }
}
