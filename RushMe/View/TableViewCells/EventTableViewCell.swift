//
//  EventTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/4/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet weak var eventNameLabel: UILabel!
  @IBOutlet weak var fraternityNameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  var event : FratEvent? = nil {
    didSet {
      if let event = self.event {
        self.timeLabel.isHidden = false
        self.fraternityNameLabel.isHidden = false
        self.eventNameLabel.isHidden = false
        self.textLabel?.isHidden = true
        let end = event.endDate.formatToHour()
        let start = event.startDate.formatToHour()
        if start != end {
          let time = start + "-" + end
          self.timeLabel?.text = time
        }
        self.eventNameLabel?.text = event.name
        self.fraternityNameLabel?.text = event.frat.name
  
      }
    }
  }
  var provideDate : Bool = false {
    didSet {
      if let event = self.event, provideDate {
        self.dateLabel?.text = DateFormatter.localizedString(from: event.startDate, 
                                                             dateStyle: .medium, 
                                                             timeStyle: .none) 
        self.dateLabel?.isHidden = false
      }
      else {
       self.dateLabel?.isHidden = true 
      }
    }
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
