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
// The DrawerMenuViewController handles 
class DrawerMenuViewController: UITableViewController {
  
  @IBOutlet var fraternitiesButton: UITableViewCell!
  
  @IBOutlet var settingsButton: UITableViewCell!
  
  @IBOutlet weak var calendarButton: UITableViewCell!
  
  @IBOutlet weak var topCell: UITableViewCell!
  var masterVC : UIViewController?
  
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = RMColor.AppColor
    self.view.backgroundColor = RMColor.AppColor
    fraternitiesButton?.backgroundColor = RMColor.MenuButtonSelectedColor
    settingsButton.backgroundColor = UIColor.clear
    calendarButton.backgroundColor = UIColor.clear
    topCell.backgroundColor = UIColor.clear
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    fraternitiesButton.isUserInteractionEnabled = true
    settingsButton.isUserInteractionEnabled = true
    calendarButton.isUserInteractionEnabled = true
    fraternitiesButton.backgroundColor = UIColor.clear
    settingsButton.backgroundColor = UIColor.clear
    calendarButton.backgroundColor = UIColor.clear
    if let id = segue.identifier {
      let selectedButton : UITableViewCell
      if (id == fraternitiesSegueIdentifier){
        selectedButton = fraternitiesButton
        self.revealViewController().pushFrontViewController(masterVC, animated: true)
      }
      else if (id == settingsSegueIdentifier){
        selectedButton = settingsButton
      }
      else if (id == calendarSegueIdentifier){
        selectedButton = calendarButton
      }
      else {
       return
      }
      selectedButton.isSelected = true
      UIView.animate(withDuration: RMAnimation.ColoringTime){
        selectedButton.backgroundColor = RMColor.MenuButtonSelectedColor
      }
      
      selectedButton.isUserInteractionEnabled = false
    }
    
    
  }
  
}

