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
  @IBOutlet weak var eventsLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  func setupView() {
    self.backgroundColor = RMColor.MenuButtonSelectedColor
    self.eventsLabel?.textColor = RMColor.AppColor
  }
}
