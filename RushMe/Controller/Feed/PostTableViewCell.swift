//
//  PollTableViewCell.swift
//  RushMe
//
//  Created by Adam Kuniholm on 2/22/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

protocol RMPollDelegate {
  func voteCast(forOption : String, inPoll : RMPoll) 
}

class PostTableViewCell: UITableViewCell {
  private(set) var pollOptions : [String] = ["None"] {
    didSet {
      for button in buttons {
        button.removeFromSuperview() 
      }
      let margins = self.layoutMarginsGuide
      //self.translatesAutoresizingMaskIntoConstraints = false
      self.contentView.translatesAutoresizingMaskIntoConstraints = false
      if pollOptions.count == 0 {
        self.layoutIfNeeded()
        return
      }
      var previousButton : UIButton? = nil
      for option in pollOptions {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor.clear//RMColor.AppColor
        button.setTitleColor(RMColor.AppColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(option, for: .normal)
        button.addTarget(self, action: #selector(PostTableViewCell.selected(_:)), for: .touchUpInside)
        self.addSubview(button)
        buttons.append(button)
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        button.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8).isActive = true
        button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8).isActive = true
        if let pButton = previousButton {
          button.topAnchor.constraint(equalTo: pButton.layoutMarginsGuide.bottomAnchor, constant: 8).isActive = true
        }
        else {
          button.topAnchor.constraint(equalTo: postDescriptionTextView.bottomAnchor, constant: 8).isActive = true
        }
        previousButton = button
      }
      self.contentView.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true
      self.contentView.heightAnchor.constraint(equalToConstant: 128 + CGFloat(pollOptions.count)*40).isActive = true
      //self.heightAnchor.constraint(equalToConstant: 256).isActive = true
      self.layoutIfNeeded()
    }
  }
  private(set) var postTitle : String = "" {
    didSet {
      self.postTitleLabel.text = postTitle 
    }
  }
  private(set) var postDescription : String = "" {
    didSet {
      self.postDescriptionTextView.text = postDescription 
    }
  }
  private(set) var post : RMPost? = nil {
    didSet {
      if let _ = post {
        postTitle = post!.title
        pollOptions = (post as? RMPoll)?.options ?? []
        
      }
    }
  }
  var isPoll : Bool {
    get {
      return !pollOptions.isEmpty 
    }
  }
  private(set) var pollDelegate : RMPollDelegate? = nil
  func set(post : RMPost) {
    self.post = post
    self.pollDelegate = nil
  }
  func set(poll : RMPoll, withDelegate newDelegate : RMPollDelegate) {
    self.pollDelegate = newDelegate
    self.post = poll
  }
  @IBOutlet weak var postFraternityLabel: UILabel!
  @IBOutlet weak var postTitleLabel: UILabel!
  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var postDescriptionTextView: UITextView!
  private var buttons = [UIButton]() 
  // TODO: Fix pollDescriptionTextView trailing constant!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    //self.postFraternityLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: -8)
    
    //self.bottomAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 8).isActive = true
    
  }
  
  @objc func selected(_ pollChoice : UIButton) {
    pollDelegate!.voteCast(forOption: pollChoice.currentTitle ?? "", inPoll: post as! RMPoll)
  }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
