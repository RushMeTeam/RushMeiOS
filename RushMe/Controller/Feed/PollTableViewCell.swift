//
//  PollTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 2/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
  var options = ["Saturday", "Sunday", "Monday"]
  
  @IBOutlet weak var pollFraternityLabel: UILabel!
  @IBOutlet weak var pollTitleLabel: UILabel!
  @IBOutlet weak var pollImageView: UIImageView!
  @IBOutlet weak var pollDescriptionTextView: UITextView!
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    let margins = self.layoutMarginsGuide
    //self.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    if options.count == 0 {
     options = ["No Options"] 
    }
    var previousButton : UIButton? = nil
    for option in options {
      let button = UIButton(type: .roundedRect)
      button.backgroundColor = UIColor.clear//RMColor.AppColor
      button.setTitleColor(RMColor.AppColor, for: .normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle(option, for: .normal)
      button.addTarget(self, action: #selector(PollTableViewCell.selected(_:)), for: .touchUpInside)
      self.addSubview(button)
      button.heightAnchor.constraint(equalToConstant: 32).isActive = true
      
      button.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8).isActive = true
      button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
      if let pButton = previousButton {
        button.topAnchor.constraint(equalTo: pButton.layoutMarginsGuide.bottomAnchor, constant: 8).isActive = true
      }
      else {
        button.topAnchor.constraint(equalTo: pollDescriptionTextView.bottomAnchor, constant: 8).isActive = true
      }
      previousButton = button
    }
    self.contentView.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true
    self.contentView.heightAnchor.constraint(equalToConstant: 128 + CGFloat(options.count)*40).isActive = true
    //self.heightAnchor.constraint(equalToConstant: 256).isActive = true
    self.layoutIfNeeded()
    
    //self.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true
    
    }

  @objc func selected(_ pollChoice : UIButton) {
    print(pollChoice.currentTitle)
  }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        // Configure the view for the selected state
    }
    
}
