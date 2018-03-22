//
//  AttractiveFratCellTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/21/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

protocol FraternityCellDelegate {
  func cell(withFratName : String, favoriteStatusToValue : Bool)
}

class AttractiveFratCellTableViewCell: UITableViewCell {
  // Fraternity name (e.g. Alpha Beta Gamma)
  @IBOutlet var titleLabel: UILabel!
  // Chapter designation (e.g. Theta)
  //  @IBOutlet var subheadingLabel: UILabel!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var previewImageView: UIImageView!
  var delegate : FraternityCellDelegate? = nil
  var gradientLayer : CAGradientLayer? = nil
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
        self.favoriteButton.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
      }
      iView.isUserInteractionEnabled = false
      favoriteButton.imageView?.contentMode = .scaleAspectFit
    }
  }
  
  @IBAction func favoriteButtonHit(_ sender: UIButton) {
    isAccentuated = !isAccentuated
    delegate?.cell(withFratName: titleLabel.text ?? "", favoriteStatusToValue: isAccentuated)
    
  }
  
  private(set) var imageBorderColor = UIColor.clear {
    didSet {
      self.previewImageView.layer.borderColor = self.imageBorderColor.cgColor
      self.layoutSubviews()
    }
  }
  var isAccentuated : Bool = false {
    didSet {
      favoriteButton.setBackgroundImage(isAccentuated ? RMImage.FavoritesImageFilled : RMImage.FavoritesImageUnfilled, for: .normal)
      imageBorderColor =  UIColor.white.withAlphaComponent(0.2) //isAccentuated ? RMColor.AppColor.withAlphaComponent(0.7) :
    }
  }
}
