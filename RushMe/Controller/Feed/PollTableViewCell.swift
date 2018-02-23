//
//  PollTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 2/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
  let options = ["Saturday", "Sunday", "Monday"]
  
  @IBOutlet weak var pollFraternityLabel: UILabel!
  @IBOutlet weak var pollTitleLabel: UILabel!
  @IBOutlet weak var pollImageView: UIImageView!
  @IBOutlet weak var pollDescriptionTextView: UITextView!
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    let margins = self.layoutMarginsGuide
    var previousButton : UIButton? = nil
    for option in options {
      let button = UIButton(type: .roundedRect)
      button.backgroundColor = RMColor.AppColor
      button.setTitleColor(UIColor.white, for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle(option, for: .normal)
      self.addSubview(button)
      button.heightAnchor.constraint(equalToConstant: 32)
      
      button.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8).isActive = true
      button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
      if let pButton = previousButton {
        button.topAnchor.constraint(equalTo: pButton.layoutMarginsGuide.bottomAnchor, constant: 8).isActive = true
      }
      else {
        button.topAnchor.constraint(equalTo: pollDescriptionTextView.layoutMarginsGuide.bottomAnchor, constant: 8).isActive = true
      }
      previousButton = button
    }
    self.contentView.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true

    self.layoutIfNeeded()
    
    //self.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        // Configure the view for the selected state
    }
    
}
