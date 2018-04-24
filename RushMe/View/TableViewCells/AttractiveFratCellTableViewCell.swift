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
    //contentView.layer.masksToBounds = true
    previewImageView.layer.masksToBounds = true
    //iView.layer.cornerRadius = RMImage.CornerRadius
    previewImageView.contentMode = UIViewContentMode.scaleAspectFill
    previewImageView.layer.cornerRadius = 5
    self.titleLabel.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    self.favoriteButton.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    previewImageView.isUserInteractionEnabled = false
    favoriteButton.imageView?.contentMode = .scaleAspectFit
    for layer in previewImageView.layer.sublayers ?? [] {
      layer.removeFromSuperlayer()
    }
    previewImageView.image = nil
    previewImageView.layer.sublayers = nil
    gradientLayer?.removeFromSuperlayer()
    gradientLayer = CAGradientLayer()
    gradientLayer!.drawsAsynchronously = true
    gradientLayer!.locations = [0.8, 1.0]
    gradientLayer!.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
    previewImageView!.layer.insertSublayer(gradientLayer!, at: 0)   
    
    
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer!.frame = previewImageView.bounds
    gradientLayer!.layoutIfNeeded()
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
      favoriteButton.setImage(isAccentuated ? RMImage.FavoritesImageFilled : RMImage.FavoritesImageUnfilled, for: .normal)
      //imageBorderColor =  UIColor.white.withAlphaComponent(0.2) //isAccentuated ? RMColor.AppColor.withAlphaComponent(0.7) :
    }
  }
}

