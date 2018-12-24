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
    dayLabel.text = "\(day)"
    eventsLabel.isHidden = eventCount == 0
    eventsLabel.text = (eventCount > 0) ? "\(min(eventNumberingCutoff, abs(eventCount)))" + 
      (abs(eventCount) > eventNumberingCutoff ? "+" : "") : nil
    eventsLabel.setNeedsLayout()
  }
  
  func set(isToday : Bool) {
    outlineCircleLayer.isHidden = !isToday
  }
  
  func set(isGrayedOut : Bool) {
    dayTextColor = isGrayedOut ? .lightGray : .black
    
  }
  
  var highlightColor : UIColor = Frontend.colors.AppColor.withAlphaComponent(0.8)
  
  var dayTextColor : UIColor = UIColor.black {
    didSet {
      dayLabel.textColor = dayTextColor
      outlineCircleLayer.strokeColor = CalendarCollectionViewCell.inactiveColor.cgColor
    }
  }
  private var circleLayer : CAShapeLayer = CAShapeLayer()
  private var outlineCircleLayer : CAShapeLayer = CAShapeLayer()
  
  var path : UIBezierPath {
    get {
      return UIBezierPath(ovalIn: dayLabel.frame.insetBy(dx: -2, dy: -2))
    }
  }
  
  
  lazy var setupCell : Void = {
    eventsLabel.isHidden = true
    eventsLabel.textColor = Frontend.colors.AppColor
    circleLayer.fillColor = Frontend.colors.AppColor.cgColor
    outlineCircleLayer.fillColor = UIColor.clear.cgColor
    outlineCircleLayer.strokeColor = circleLayer.fillColor
    outlineCircleLayer.lineWidth = 0.5
    circleLayer.path = path.cgPath
    outlineCircleLayer.path = path.cgPath
    
    layer.addSublayer(outlineCircleLayer)
    layer.addSublayer(circleLayer)
    circleLayer.zPosition = -0.01
    outlineCircleLayer.zPosition = -0.01
    eventsLabel.layer.zPosition = 0
    eventsLabel.layer.masksToBounds = false
    layer.masksToBounds = false
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
      outlineCircleLayer.path = path.cgPath
    }
  }
  
  
  
}
