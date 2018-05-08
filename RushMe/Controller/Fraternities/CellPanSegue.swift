//
//  CellPanSegue.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/4/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class CellPanSegue: UIStoryboardSegue {
  override func perform() {
    var firstVCView = self.source.view!
    var secondVCView = self.destination.view!
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    secondVCView.frame = CGRect.init(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
    let window = UIApplication.shared.keyWindow
    window?.insertSubview(secondVCView, aboveSubview: firstVCView)
    UIView.animate(withDuration: 0.2, animations: { 
      secondVCView.frame = secondVCView.frame.offsetBy(dx: screenWidth, dy: 0)
    }) { (_) in
      self.source.dismiss(animated: false, completion: nil)
    }
  }
}
