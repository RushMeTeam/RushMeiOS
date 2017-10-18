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
  
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = COLOR_CONST.MENU_COLOR
    self.view.backgroundColor = COLOR_CONST.MENU_COLOR
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print(segue.description)
    
    
  }
  
}

