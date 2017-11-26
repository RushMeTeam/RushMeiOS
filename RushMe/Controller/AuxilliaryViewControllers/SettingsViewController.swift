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

  @IBOutlet weak var qualityPicker: UISegmentedControl!
  
  @IBOutlet weak var displayPastEventsSwitch: UISwitch!
  
  override func viewDidLoad() {
    if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      drawerButton.target = self.revealViewController()
      drawerButton.action = #selector(self.revealViewController().revealToggle(_:))
      // Allow drag to open drawer, tap out to close
      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    }
    displayPastEventsSwitch.isOn = Campus.shared.considerEventsBeforeToday
    if Campus.shared.downloadedImageQuality == .High {
     qualityPicker.selectedSegmentIndex = 2
    }
    if Campus.shared.downloadedImageQuality == .Medium {
      qualityPicker.selectedSegmentIndex = 1
    }
    if Campus.shared.downloadedImageQuality == .Low {
      qualityPicker.selectedSegmentIndex = 0
    }
    super.viewDidLoad()
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    navigationController?.navigationBar.tintColor = RMColor.AppColor
    
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if qualityPicker?.selectedSegmentIndex == 0 {
     Campus.shared.downloadedImageQuality = .Low
    }
    else if qualityPicker?.selectedSegmentIndex == 1 {
     Campus.shared.downloadedImageQuality = .Medium
    }
    else if qualityPicker?.selectedSegmentIndex == 2 {
     Campus.shared.downloadedImageQuality = .High
    }
    Campus.shared.considerEventsBeforeToday = displayPastEventsSwitch!.isOn
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
