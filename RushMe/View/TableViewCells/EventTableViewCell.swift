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
  
  var event : FratEvent? = nil {
    didSet {
      if let event = self.event {
        //self.timeLabel.isHidden = false
        self.fraternityNameLabel.isHidden = false
        self.eventNameLabel.isHidden = false
        self.textLabel?.isHidden = true
        let end = event.endDate.formatToHour()
        let start = event.startDate.formatToHour()
        
        self.dateLabel?.text = DateFormatter.localizedString(from: event.startDate,
                                                             dateStyle: .short,
                                                             timeStyle: .none)
        if start != end {
          let time = " " + start + "-" + end
          self.dateLabel?.text?.append(time)
        }
        self.eventNameLabel?.text = event.name
        let greekLetters = event.frat.name.greekLetters
        if greekLetters.count > 3 {
          let letterArray = event.frat.name.replacingOccurrences(of: " of", with: " ").split(separator: " ").map { (subString) -> Character in
            return subString.first ?? Character.init("")
          }
          var letters = ""
          for i in 0...min(letterArray.count, 3)-1 {
           letters.append(letterArray[i])
          }
          if letters.count < 2 {
           self.fraternityNameLabel.text = greekLetters.substring(to: 3)
          } else {
            self.fraternityNameLabel.text = letters
          }
         // self.fraternityNameLabel?.text =
        } else {
         self.fraternityNameLabel.text = event.frat.name.greekLetters
        }
        
  
      }
    }
  }
  var provideDate : Bool = false {
    didSet {
      if let event = self.event, provideDate {
        //self.dateLabel?.text = DateFormatter.localizedString(from: event.startDate,
                                                            // dateStyle: .medium,
                                                             //timeStyle: .none)
        //self.dateLabel?.isHidden = false
      }
      else {
       //self.dateLabel?.isHidden = true
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

extension String {
  func index(from: Int) -> Index {
    return self.index(startIndex, offsetBy: from)
  }
  
  func substring(from: Int) -> String {
    let fromIndex = index(from: from)
    return substring(from: fromIndex)
  }
  
  func substring(to: Int) -> String {
    let toIndex = index(from: to)
    return substring(to: toIndex)
  }
  
  func substring(with r: Range<Int>) -> String {
    let startIndex = index(from: r.lowerBound)
    let endIndex = index(from: r.upperBound)
    return substring(with: startIndex..<endIndex)
  }
}
