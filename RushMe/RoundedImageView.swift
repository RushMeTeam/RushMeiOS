//
//  RoundedImageView.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/14/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//
import UIKit

class RoundedImageView: UIImageView {
    override func draw(_ rect: CGRect) {
        // Drawing code
      super.draw(rect)
      self.layer.cornerRadius = IMAGE_CONST.CORNER_RADIUS
      self.layer.masksToBounds = true
      
    }
 
  

}
