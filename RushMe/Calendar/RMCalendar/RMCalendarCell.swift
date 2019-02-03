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


class RMCalendarCell: FSCalendarCell {
  
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
    
    let circleImageView = UIView()
    self.contentView.insertSubview(circleImageView, at: 0)
    self.circleView = circleImageView
    
    let selectionLayer = CAShapeLayer()
    selectionLayer.fillColor = Frontend.colors.SelectionColor.cgColor
    selectionLayer.actions = ["hidden": NSNull()]
    self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
    self.selectionLayer = selectionLayer
    
    self.shapeLayer.isHidden = false
    let view = UIView(frame: self.bounds)
    self.backgroundView = view
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.circleView.frame = self.contentView.bounds.insetBy(dx: 2, dy: 2)
    self.backgroundView?.frame = self.bounds
    self.selectionLayer.frame = self.contentView.bounds.insetBy(dx: 2, dy: 2)
  
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
