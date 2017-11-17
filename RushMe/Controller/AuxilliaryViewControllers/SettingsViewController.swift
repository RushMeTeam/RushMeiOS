//
//  SettingsViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/13/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
// A simple UIViewController for settings, will handle
// data. In the future, will probably need a delegate
class SettingsViewController: UIViewController {
  // Button to toggle UIImageView
  @IBOutlet var drawerButton: UIBarButtonItem!
  override func viewDidLoad() {
      if (self.revealViewController() != nil) {
        // Allow drawer button to toggle the lefthand drawer menu
        drawerButton.target = self.revealViewController()
        drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
        // Allow drag to open drawer, tap out to close
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
      }
      super.viewDidLoad()
      
      
    }

    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
