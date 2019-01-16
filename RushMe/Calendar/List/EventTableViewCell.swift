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
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var fratLabel: UILabel!
  @IBOutlet weak var eventNameLabel: UILabel!
  @IBOutlet weak var addButton: UIButton!
  
  static var addImage : UIImage? {
    get {
     return UIImage(imageLiteralResourceName: "bellUnfilled")
    }
  }
  static var removeImage : UIImage? {
    get {
      return UIImage(imageLiteralResourceName: "bell")
    }
  }
  
  func set(isFavorited : Bool) {
    let newImage = isFavorited ? EventTableViewCell.removeImage : EventTableViewCell.addImage
    addButton.setImage(newImage, for: .normal)
  }
  
  var event : Fraternity.Event? = nil {
    didSet {
      if let event = self.event {
        self.eventNameLabel.isHidden = false
        self.textLabel?.isHidden = true
        let end = event.ending.formatToHour()
        let start = event.starting.formatToHour()
        let formatter = DateFormatter.init()
        formatter.dateFormat = "MM.dd.yy"
        self.dateLabel?.text = formatter.string(from: event.starting)
        self.fratLabel?.text = event.frat.name.uppercased()
        
        if start != end {
          self.timeLabel?.text = start
        }
        self.eventNameLabel?.text = event.name
      }
    }
  }
  var provideDate : Bool = false 
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.layer.masksToBounds = false
    
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
