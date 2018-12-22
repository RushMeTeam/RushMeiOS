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
  @IBOutlet weak var addButton: UIButton!
  
  @IBAction func add(_ sender: UIButton) {
    guard let _ = event else { return }
    if User.session.selectedEvents.contains(event!) {
      User.session.selectedEvents.remove(event!)
      
    } else {
      User.session.selectedEvents.insert(event!)
    }
    updateButtonState()
    
  }
  
  private func updateButtonState() {
    if !User.session.selectedEvents.contains(event!) {
      addButton.setImage(UIImage.init(imageLiteralResourceName: "add"), for: .normal)
    } else { 
      addButton.setImage(UIImage.init(imageLiteralResourceName: "XOutIcon"), for: .normal)
    }
  }
  var event : Fraternity.Event? = nil {
    didSet {
      if let event = self.event {
        updateButtonState()
        self.fraternityNameLabel.isHidden = false
        self.eventNameLabel.isHidden = false
        self.textLabel?.isHidden = true
        let end = event.ending.formatToHour()
        let start = event.starting.formatToHour()
        self.dateLabel?.text = DateFormatter.localizedString(from: event.starting,
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
  var provideDate : Bool = false 
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    

}

extension String {
  func index(from: Int) -> Index {
    return self.index(startIndex, offsetBy: from)
  }
  
  func substring(from: Int) -> String {
    return String(self[index(from: from)...])
  }
  
  func substring(to: Int) -> String {
    return String(self[...index(from: to)])
  }
  
  func substring(with r: Range<Int>) -> String {
    let startIndex = index(from: r.lowerBound)
    let endIndex = index(from: r.upperBound)
    return String(self[startIndex..<endIndex])
  }
}
