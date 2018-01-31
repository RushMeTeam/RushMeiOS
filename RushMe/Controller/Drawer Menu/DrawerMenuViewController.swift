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

// The DrawerMenuViewController handles all sidebar navigation, managing all
// animation and user interaction
class DrawerMenuViewController: UITableViewController {
  
  @IBOutlet var eventsButton: UITableViewCell!
  @IBOutlet var fraternitiesButton: UITableViewCell!
  @IBOutlet var settingsButton: UITableViewCell!
  @IBOutlet var calendarButton: UITableViewCell!
  @IBOutlet var mapButton: UITableViewCell!
  @IBOutlet var topCell: UITableViewCell!
  @IBOutlet var buttons: [UITableViewCell]!
  var masterVC : UIViewController?
  
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = RMColor.AppColor
    self.view.backgroundColor = RMColor.AppColor
    self.topCell.backgroundColor = UIColor.clear
    // When this View Controller is first created, we are currently
    // viewing fraternities-- set all other buttons to deselected state
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
      // Find the selected button by matching segue identifier
      // with button (a UITableCell) reuse identifier
      for button in buttons {
        if button.reuseIdentifier == id{
          selectedButton = button
        }
        else {
          // Reset all buttons to clear
          button.backgroundColor = UIColor.clear
        }
        // Make all buttons interact-able
        button.isUserInteractionEnabled = true
      }
      if let _ = selectedButton {
        SQLHandler.shared.informAction(action: "User navigated to ", options: id)
        // Animate selected button to show selection
        selectedButton!.isSelected = true
        UIView.animate(withDuration: RMAnimation.ColoringTime, animations: {
          selectedButton!.backgroundColor = RMColor.MenuButtonSelectedColor
        }, completion: { (_) in
          selectedButton!.isUserInteractionEnabled = false
        })
        if selectedButton == fraternitiesButton {
          // Particular segue for fraternities tab
         self.revealViewController().pushFrontViewController(masterVC, animated: true) 
        }
      }
    }
  }
}


