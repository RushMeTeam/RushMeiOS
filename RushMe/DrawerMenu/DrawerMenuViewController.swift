//
//  DrawerMenuViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/8/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import Foundation
import UIKit

class DrawerMenuViewController: UITableViewController {
  
  @IBOutlet var fraternitiesButton: UITableViewCell!
  
  @IBOutlet var favoritesButton: UITableViewCell!
  
  @IBOutlet var settingsButton: UITableViewCell!
  
  var lastSelected : UIViewController?
  
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = COLOR_CONST.MENU_COLOR
    self.view.backgroundColor = COLOR_CONST.MENU_COLOR
    fraternitiesButton?.backgroundColor = COLOR_CONST.MENU_BUTTON_SELECTED_COLOR
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    fraternitiesButton.isUserInteractionEnabled = true
    settingsButton.isUserInteractionEnabled = true
    //favoritesButton.isUserInteractionEnabled = true
    fraternitiesButton.backgroundColor = UIColor.clear
    settingsButton.backgroundColor = UIColor.clear
    favoritesButton.backgroundColor = UIColor.clear
    if let id = segue.identifier {
      let selectedButton : UITableViewCell
      if (id == "Fraternities"){
        selectedButton = fraternitiesButton
        
      }
      else if (id == "Settings"){
        selectedButton = settingsButton
      }
      else if (id == "Favorites"){
        selectedButton = favoritesButton
      }
      else {
       return
      }
      selectedButton.isSelected = true
      UIView.animate(withDuration: ANIM_CONST.COLORING_TIME){
        selectedButton.backgroundColor = COLOR_CONST.MENU_BUTTON_SELECTED_COLOR
      }
      
      selectedButton.isUserInteractionEnabled = false
    }
    
    
  }
  
}

