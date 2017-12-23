//
//  DrawerMenuViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

fileprivate let fraternitiesSegueIdentifier = "Fraternities"
fileprivate let settingsSegueIdentifier = "Settings"
fileprivate let calendarSegueIdentifier = "Calendar"
fileprivate let mapSegueIdentifier = "Maps"
fileprivate let eventsSegueIdentifier = "Events"
fileprivate let chatSegueIdentifier = "Chat"
// The DrawerMenuViewController handles 
class DrawerMenuViewController: UITableViewController {
  
  @IBOutlet var eventsButton: UITableViewCell!
  @IBOutlet var fraternitiesButton: UITableViewCell!
  @IBOutlet var settingsButton: UITableViewCell!
  @IBOutlet var calendarButton: UITableViewCell!
  @IBOutlet var mapButton: UITableViewCell!
  @IBOutlet var topCell: UITableViewCell!
  @IBOutlet var chatButton: UITableViewCell!
  @IBOutlet var buttons: [UITableViewCell]!
//  
//  var buttons : [String : UITableViewCell] {
//    get {
//      return [fraternitiesSegueIdentifier : self.fraternitiesButton, 
//              settingsSegueIdentifier     : self.settingsButton, 
//              mapSegueIdentifier          : self.mapButton, 
//              calendarSegueIdentifier     : self.calendarButton,
//              eventsSegueIdentifier       : self.eventsButton,
//              "" : self.topCell]
//    }
//  }
  var masterVC : UIViewController?
  
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = RMColor.AppColor
    self.view.backgroundColor = RMColor.AppColor
    self.topCell.backgroundColor = UIColor.clear
    
    for button in buttons {
      button.isUserInteractionEnabled = true
      button.backgroundColor = UIColor.clear
    }
    fraternitiesButton.backgroundColor = RMColor.MenuButtonSelectedColor
    fraternitiesButton.isUserInteractionEnabled = false
    
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let id = segue.identifier {
      var selectedButton : UITableViewCell? 
      for button in buttons {
        if button.reuseIdentifier == id{
          selectedButton = button
        }
        else {
          button.backgroundColor = UIColor.clear
        }
        button.isUserInteractionEnabled = true
      }
      if let _ = selectedButton {
        selectedButton!.isSelected = true
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
          selectedButton!.backgroundColor = RMColor.MenuButtonSelectedColor
        }, completion: { (_) in
          selectedButton!.isUserInteractionEnabled = false
        })
        if selectedButton == fraternitiesButton {
         self.revealViewController().pushFrontViewController(masterVC, animated: true) 
        }
      }
    }
  }
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//    if (identifier == "Chat Button") {
//      self.revealViewController().pushFrontViewController(storyboard!.instantiateViewController(withIdentifier: "chatNavVC"), animated: true)
//     return false 
//    }
    return true
  }
}


