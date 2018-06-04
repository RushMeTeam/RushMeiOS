//
//  CalendarCollectionViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/2/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
  var eventsToday : [FratEvent]?
  var highlightColor : UIColor = RMColor.AppColor.withAlphaComponent(0.8)
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
    eventsLabel.textColor = RMColor.AppColor
    circleLayer.fillColor = RMColor.AppColor.cgColor
    layer.addSublayer(circleLayer)
    circleLayer.zPosition = -0.01
    eventsLabel.layer.zPosition = 0
    eventsLabel.text = ""
    eventsLabel.layer.masksToBounds = false
    layer.masksToBounds = false
    //addMotionEffect(UIMotionEffect.twoAxesShift(strength: 10))
    bringSubview(toFront: eventsLabel)
  }()
  @IBOutlet weak var eventsLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    _ = setupCell
    eventsLabel.textColor = RMColor.AppColor
    circleLayer.fillColor = RMColor.AppColor.cgColor
  }
  override var isSelected: Bool {
    didSet {
      circleLayer.fillColor = (isSelected ? highlightColor : .clear).cgColor
      dayLabel.textColor = isSelected ? UIColor.white : dayTextColor
      circleLayer.path = path.cgPath
    }
  }
  

  
}
