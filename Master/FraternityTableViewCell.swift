//
//  AttractiveFratCellTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/21/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit


class FraternityTableViewCell: UITableViewCell {
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
      if let _ = newValue {
        titleLabel.text = newValue!.name
        favoriteButton.accessibilityIdentifier = (titleLabel.text ?? "") + " Favorites Button"
        isAccentuated = newValue!.isFavorite
      } else {
        titleLabel.text = ""
        isAccentuated = false
      }
    }
    get {
     return Campus.shared.fraternitiesByName[titleLabel.text ?? ""]  
    }
  }
  func loadImage() {
    if let profileImageURL = fraternity?.profileImagePath{
      previewImageView.setImageByURL(fromSource: profileImageURL)
    }
  }
 
  
  lazy var setupCell : Void = {
    previewImageView.layer.masksToBounds = true
    previewImageView.contentMode = UIView.ContentMode.scaleAspectFill
    previewImageView.layer.cornerRadius = 8
    //titleLabel.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    previewImageView.isUserInteractionEnabled = false
    favoriteButton.imageView?.contentMode = .scaleAspectFit
    //favoriteButton.addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
  }()
  override func awakeFromNib() {
    super.awakeFromNib()
    _ = setupCell
    previewImageView.image = nil
    titleLabel.layer.shadowRadius = 10
    titleLabel.layer.shadowColor = UIColor.black.cgColor
    titleLabel.layer.shadowOffset = CGSize.init(width: 1, height: 1)
    titleLabel.layer.masksToBounds = false
  }

  override func layoutSubviews() {
    
    super.layoutSubviews()
  }
  @IBAction func favoriteButtonHit(_ sender: UIButton? = nil) {
    isAccentuated = !isAccentuated
    delegate?.cell(withFratName: titleLabel.text ?? "", favoriteStatusToValue: isAccentuated)
  }

  var imageBorderColor : UIColor {
    set {
      DispatchQueue.main.async {
        self.previewImageView.layer.borderColor = newValue.cgColor
        self.layoutSubviews()
      }
    } get {
      if let color = self.previewImageView.layer.borderColor {
       return UIColor(cgColor: color)
      } else {
       return .clear
      }
    }
  }
  var isAccentuated : Bool = false {
    didSet {
      favoriteButton.setImage(isAccentuated ? Frontend.images.filledHeart : Frontend.images.unfilledHeart, for: .normal)
      //imageBorderColor =  UIColor.white.withAlphaComponent(0.2) //isAccentuated ? RMColor.AppColor.withAlphaComponent(0.7) :
    }
  }
}



