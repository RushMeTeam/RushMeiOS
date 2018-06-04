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
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var previewImageView: UIImageView!
  var delegate : FraternityCellDelegate? = nil
  var gradientLayer : CAGradientLayer? = nil
  
  var fraternity : Fraternity? {
    set {
      titleLabel.text = newValue?.name
      favoriteButton.accessibilityIdentifier = (titleLabel.text ?? "") + " Favorites Button"
      isAccentuated = Campus.shared.favoritedFrats.contains(newValue?.name ?? "")
    }
    get {
     return Campus.shared.fraternitiesDict[titleLabel.text ?? ""]  
    }
  }
  func loadImage() {
    if let profileImageURL = fraternity?.profileImagePath{
    previewImageView.setImageByURL(fromSource: profileImageURL) 
    }
  }
 
  
  lazy var setupCell : Void = {
    previewImageView.layer.masksToBounds = true
    previewImageView.contentMode = UIViewContentMode.scaleAspectFill
    previewImageView.layer.cornerRadius = 8
    //titleLabel.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    previewImageView.isUserInteractionEnabled = false
    favoriteButton.imageView?.contentMode = .scaleAspectFit
    //favoriteButton.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
  }()
  override func awakeFromNib() {
    super.awakeFromNib()
    _ = setupCell
    // Initialization code
    //contentView.layer.masksToBounds = true
    
    //iView.layer.cornerRadius = RushMe.images.CornerRadius
    
    
    
//    for layer in previewImageView.layer.sublayers ?? [] {
//      layer.removeFromSuperlayer()
//    }
    previewImageView.image = nil
    //previewImageView.layer.sublayers = nil
//    gradientLayer?.removeFromSuperlayer()
//    gradientLayer = CAGradientLayer()
//    gradientLayer!.drawsAsynchronously = true
//    gradientLayer!.locations = [0.8, 1.0]
//    gradientLayer!.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
//    previewImageView!.layer.insertSublayer(gradientLayer!, at: 0)   
    titleLabel.layer.shadowRadius = 10
    titleLabel.layer.shadowColor = UIColor.black.cgColor
    titleLabel.layer.shadowOffset = CGSize.init(width: 1, height: 1)
    titleLabel.layer.masksToBounds = false
  
    
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    //gradientLayer?.frame = previewImageView.bounds
    //gradientLayer?.layoutIfNeeded()
  }
  @IBAction func favoriteButtonHit(_ sender: UIButton? = nil) {
    isAccentuated = !isAccentuated
    delegate?.cell(withFratName: titleLabel.text ?? "", favoriteStatusToValue: isAccentuated)
    
  }

  
  private(set) var imageBorderColor = UIColor.clear {
    didSet {
      previewImageView.layer.borderColor = self.imageBorderColor.cgColor
      layoutSubviews()
    }
  }
  var isAccentuated : Bool = false {
    didSet {
      favoriteButton.setImage(isAccentuated ? RushMe.images.filledHeart : RushMe.images.unfilledHeart, for: .normal)
      //imageBorderColor =  UIColor.white.withAlphaComponent(0.2) //isAccentuated ? RMColor.AppColor.withAlphaComponent(0.7) :
    }
  }
}



