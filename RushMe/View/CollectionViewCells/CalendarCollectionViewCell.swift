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
  @IBOutlet weak var eventsLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    self.eventsLabel?.textColor = RMColor.AppColor
    self.circleLayer.fillColor = RMColor.AppColor.cgColor
    self.layer.addSublayer(circleLayer)
    circleLayer.zPosition = -0.01
    eventsLabel.layer.zPosition = 0
    self.bringSubview(toFront: eventsLabel)
  }
  override var isSelected: Bool {
    didSet {
      circleLayer.fillColor = (isSelected ? highlightColor : UIColor.clear).cgColor
      dayLabel.textColor = isSelected ? UIColor.white : dayTextColor
      if circleLayer.path == nil {
        circleLayer.path = path.cgPath
      }
    }
  }
  private var circleLayer : CAShapeLayer = CAShapeLayer()
  var path : UIBezierPath {
    get {
      let p = UIBezierPath.init(ovalIn: self.dayLabel.frame)
      return p
    }
  }

  
}
