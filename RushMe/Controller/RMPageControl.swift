//
//  RMPageControl.swift
//  RushMe
//
//  Created by Adam Kuniholm on 3/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
enum ViewCategory : String {
  case map = "mapsIcon"
  case fraternities = "fraternitiesIcon"
  case calendar = "eventsIcon"
  var button : UIButton {
    get {
     let button = UIButton()
      button.setImage(UIImage(named: rawValue), for: .normal)
      return button
    }
  }
}


protocol RMPageControlDelegate {
  func selectedIndex(_ index : Int) 
}

class RMPageControl: NSObject {
  var stackView : UIStackView
  var delegate : RMPageControlDelegate?
  init(categories : [ViewCategory]) {
    var buttons = [UIButton]()
    for category in categories {
      buttons.append(category.button)
    }
    stackView = UIStackView(arrangedSubviews: buttons)
    stackView.spacing = 20
    stackView.distribution = .fillEqually
    stackView.alignment = .center
    super.init()
    for button in buttons {
      button.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
    }
    
    
  }
  func selectIndex(_ index : Int) {
    for button in (stackView.subviews) as! [UIButton] {
      button.isSelected = true
    }
  }
  @objc func selected(sender : UIButton) {
    for button in (stackView.subviews) as! [UIButton] {
     button.isSelected = (button == sender) 
    }
    delegate?.selectedIndex((stackView.subviews.index(of: sender))!)
  }
}
