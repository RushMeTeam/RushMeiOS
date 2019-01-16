//
//  DIYCalendarCell.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation

import UIKit

import FSCalendar

enum SelectionType : Int {
  case none
  case single
  case leftBorder
  case middle
  case rightBorder
}


class DIYCalendarCell: FSCalendarCell {
  
  weak var circleView: UIView!
  weak var selectionLayer: CAShapeLayer!
  
  var selectionType: SelectionType = .none {
    didSet {
      setNeedsLayout()
    }
  }
  
  required init!(coder aDecoder: NSCoder!) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    //self.titleLabel.font.pointSize = 15

    
    let circleImageView = UIView()
    self.contentView.insertSubview(circleImageView, at: 0)
    self.circleView = circleImageView
    
    let selectionLayer = CAShapeLayer()
    selectionLayer.fillColor = Frontend.colors.SelectionColor.cgColor
    selectionLayer.actions = ["hidden": NSNull()]
    self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
    self.selectionLayer = selectionLayer
    
    self.shapeLayer.isHidden = true
    let view = UIView(frame: self.bounds)
    self.backgroundView = view
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.circleView.frame = self.contentView.bounds
    self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
    self.selectionLayer.frame = self.contentView.bounds
    
    //self.shapeLayer.path = UIBezierPath.init(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2, width: diameter/3, height: diameter/3)).cgPath
    
    
    
    if selectionType == .single {
      let diameter: CGFloat = min(self.titleLabel.frame.height, self.titleLabel.frame.width)
      let rect = CGRect(x: self.contentView.frame.width/2 - diameter/2, y: self.titleLabel.frame.origin.y, width: diameter, height: diameter).insetBy(dx: 3, dy: 3)
      
      self.selectionLayer.path = UIBezierPath(ovalIn: rect).cgPath
    }
  }
  
  override func configureAppearance() {
    super.configureAppearance()
    
    self.eventIndicator.isHidden = false
    // Override the build-in appearance configuration
    if self.isPlaceholder {
      self.titleLabel.textColor = UIColor.lightGray
    }
  }
  
}
