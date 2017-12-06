//
//  EventTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/4/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

  // @IBOutlet weak var addressTextView: UITextView!
  @IBOutlet weak var eventNameLabel: UILabel!
  @IBOutlet weak var fraternityNameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
