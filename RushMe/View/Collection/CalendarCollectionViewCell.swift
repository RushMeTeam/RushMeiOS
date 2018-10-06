//
//  CalendarCollectionViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

fileprivate var eventNumberingCutoff = 9 

class CalendarCollectionViewCell: UICollectionViewCell {
  static var inactiveColor : UIColor = .lightGray
  static var activeColor : UIColor = .black
  
  func set(day : Int, eventCount: Int) {
    // TODO: Events label is not being hidden!!!
    dayLabel.text = "\(day)"
    if eventCount > 0 {
      eventsLabel.isHidden = false
      eventsLabel.text = "\(min(eventNumberingCutoff, abs(eventCount)))" + (abs(eventCount) > eventNumberingCutoff ? "+" : "")
    } else {
      eventsLabel.isHidden = true
    }
    eventsLabel.setNeedsLayout()
  }
  
  func set(isGrayedOut : Bool) {
    dayTextColor = isGrayedOut ? .lightGray : .black
  }
  
  
  var highlightColor : UIColor = Frontend.colors.AppColor.withAlphaComponent(0.8)
  var dayTextColor : UIColor = UIColor.black {
    didSet {
     dayLabel.textColor = dayTextColor
    }
  }
  private var circleLayer : CAShapeLayer = CAShapeLayer()
  var path : UIBezierPath {
    get {
      return UIBezierPath(ovalIn: dayLabel.frame.insetBy(dx: -2, dy: -2))
    }
  }
  lazy var setupCell : Void = {
    eventsLabel.textColor = Frontend.colors.AppColor
    circleLayer.fillColor = Frontend.colors.AppColor.cgColor
    layer.addSublayer(circleLayer)
    circleLayer.zPosition = -0.01
    eventsLabel.layer.zPosition = 0
    eventsLabel.layer.masksToBounds = false
    layer.masksToBounds = false
    //addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    bringSubviewToFront(eventsLabel)
  }()
  @IBOutlet weak var eventsLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    _ = setupCell
    eventsLabel.textColor = Frontend.colors.AppColor
    circleLayer.fillColor = Frontend.colors.AppColor.cgColor
  }
  override var isSelected: Bool {
    didSet {
      circleLayer.fillColor = (isSelected ? highlightColor : .clear).cgColor
      dayLabel.textColor = isSelected ? UIColor.white : dayTextColor
      circleLayer.path = path.cgPath
    }
  }
  

  
}
