//
//  AttractiveFratCellTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/21/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class AttractiveFratCellTableViewCell: UITableViewCell {
  // Fraternity name (e.g. Alpha Beta Gamma)
  @IBOutlet weak var titleLabel: UILabel!
  // Chapter designation (e.g. Theta)
//  @IBOutlet var subheadingLabel: UILabel!
  @IBOutlet weak var previewImageView: UIImageView!
  weak var gradientLayer : CAGradientLayer? = nil
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    if let iView = previewImageView {
      iView.layer.masksToBounds = true
      //iView.layer.cornerRadius = RMImage.CornerRadius
      iView.contentMode = UIViewContentMode.scaleAspectFill
      iView.layer.borderColor = imageBorderColor.cgColor
      iView.layer.borderWidth = 2
      // If there is no preview image
      if (iView.image == nil){
        iView.image = RMImage.NoImage
      }
      if gradientLayer == nil {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = iView.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0.5, 1.0]
        iView.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        self.titleLabel.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
      }
      iView.isUserInteractionEnabled = false
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    // Do nothing
    //super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  var imageBorderColor = UIColor.clear {
    didSet {
      UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
        self.previewImageView.layer.borderColor = self.imageBorderColor.cgColor
      })
    }
  }
  override func layoutSubviews() {

  }
}
