//
//  SegmentCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/28/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class SegmentCell: UITableViewCell {

  @IBOutlet var segmentControl: UISegmentedControl!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
