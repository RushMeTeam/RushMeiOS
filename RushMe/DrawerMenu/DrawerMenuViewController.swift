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
  override func viewDidLoad() {
    tableView.isScrollEnabled = false
    tableView.backgroundColor = COLOR_CONST.MENU_COLOR
    
  }
}

