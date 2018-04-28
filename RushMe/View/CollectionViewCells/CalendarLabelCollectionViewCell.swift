//
//  CalendarLabelCollectionViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 1/17/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class CalendarLabelCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var dayLabel: UILabel!
  var eventsToday : [FratEvent]?  
}

