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
  @IBOutlet weak var fratButton: UIButton!
  @IBOutlet weak var eventNameLabel: UILabel!
  @IBOutlet weak var addButton: UIButton!
  
  @IBOutlet weak var calendarButton: UIButton!
  @IBOutlet weak var clipboardButton: UIButton!
  
  @IBOutlet weak var expandedView: UIStackView!
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
//    expandedView.isHidden = !isSelected
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    expandedView.isHidden = !selected
  }
  
  func set(event : Fraternity.Event) {
    self.eventNameLabel.isHidden = false
    self.textLabel?.isHidden = true
    let end = event.ending.formatToHour()
    let start = event.starting.formatToHour()
    let formatter = DateFormatter()
    formatter.dateFormat = "MM.dd.yy"
    self.dateLabel?.text = formatter.string(from: event.starting)
    let fratNameLocation = event.frat.name.uppercased() + (event.location != nil ? " | " + event.location! : "") 
    self.fratButton.setTitle(fratNameLocation, for: .normal)
    if start != end {
      self.timeLabel?.text = start + " - " + end
    }
    self.eventNameLabel?.text = event.name
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.layer.masksToBounds = false
    
  }
}
