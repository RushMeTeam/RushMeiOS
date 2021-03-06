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
  // Button to toggle slideout menu
  @IBOutlet var drawerButton: UIBarButtonItem!
  // Allow user to pick desired quality of downloaded images
  @IBOutlet weak var qualityPicker: UISegmentedControl!
  // Allow user to choose whether to display/consider past events
  @IBOutlet weak var displayPastEventsSwitch: UISwitch!

  @IBOutlet weak var shuffleFraternitiesSwitch: UISwitch!
  
  @IBOutlet weak var appVersionLabel: UILabel!
  
  @IBOutlet weak var debugStackView: UIStackView!
  
  
  @IBOutlet weak var simulateDateButton: UIButton!
  @IBOutlet weak var simulatedDatePicker: UIDatePicker!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let buildVersion = (User.device.properties["appv"] as! String).split(separator: "-")
    appVersionLabel.text = "RushMe Version \(buildVersion[0]) Build \(buildVersion[1])"
    appVersionLabel.textColor = Frontend.colors.AppColor
    //if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      // Allow drag to open drawer, tap out to close
//      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    //}
  
    // Visual details
    self.shuffleFraternitiesSwitch.tintColor = Frontend.colors.AppColor
    self.shuffleFraternitiesSwitch.onTintColor = Frontend.colors.AppColor
    self.qualityPicker.tintColor = Frontend.colors.AppColor
    
    self.displayPastEventsSwitch.tintColor = Frontend.colors.AppColor
    self.displayPastEventsSwitch.onTintColor = Frontend.colors.AppColor
    // Update UI to match current settings
    
    displayPastEventsSwitch.isOn = User.preferences.considerPastEvents
    if Campus.downloadedImageQuality == .High {
     qualityPicker.selectedSegmentIndex = 2
    }
    if Campus.downloadedImageQuality == .Medium {
      qualityPicker.selectedSegmentIndex = 1
    }
    if Campus.downloadedImageQuality == .Low {
      qualityPicker.selectedSegmentIndex = 0
    }
    
    simulatedDatePicker.date = User.debug.debugDate ?? Date()
    simulateDateButton.isEnabled = User.debug.debugDate != nil
    
    shuffleFraternitiesSwitch.isOn = User.preferences.shuffleEnabled
    clearCacheButton.isEnabled = FileManager.default.fileExists(atPath: User.files.fratImageURL.path)
    
    debugStackView.isHidden = !User.debug.isEnabled
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Update settings to match UI
    if qualityPicker?.selectedSegmentIndex == 0 {
     Campus.downloadedImageQuality = .Low
    }
    else if qualityPicker?.selectedSegmentIndex == 1 {
     Campus.downloadedImageQuality = .Medium
    }
    else if qualityPicker?.selectedSegmentIndex == 2 {
     Campus.downloadedImageQuality = .High
    }
    User.preferences.considerPastEvents = displayPastEventsSwitch!.isOn
    
    User.preferences.shuffleEnabled = shuffleFraternitiesSwitch.isOn
  }

  @IBAction func shuffleFraternitiesSwitch(_ sender: UISwitch) {
    User.preferences.shuffleEnabled = sender.isOn
  }
  
  @IBAction func displayPastEventsSwitched(_ sender: UISwitch) {
    User.preferences.considerPastEvents = sender.isOn
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func simuatedDatePicked(_ sender: UIDatePicker) {
    User.debug.debugDate = simulatedDatePicker.date
    simulateDateButton.isEnabled = true
  }
  
  @IBAction func disableDateSimulation(_ sender: UIButton) {
    User.debug.debugDate = nil
    simulatedDatePicker.date = Date()
  }
  
  
  
  @IBOutlet weak var clearCacheButton: UIButton!
  @IBAction func clearCache(_ sender: UIButton) {
    var fileSize = 0.0
    var fileNumber = 0
    let _ = FileManager.default.subpaths(atPath: User.files.fratImageURL.path)?.forEach({ (fileName) in
      fileSize += ((try? FileManager.default.attributesOfItem(atPath: User.files.fratImageURL.appendingPathComponent(fileName).path)[FileAttributeKey.size] as? Double ?? nil) ?? nil) ?? 0
      fileNumber += 1
    })
    let deleteAlert = UIAlertController.init(title: String(format: "Free %.1f mb", fileSize/1000000.0), message: nil, preferredStyle: .actionSheet)
    deleteAlert.addAction(UIAlertAction.init(title: "Delete \(fileNumber) image\((fileNumber > 1 ? "s" : ""))", style: .destructive, handler: { (action) in
      self.clearCache()
    }))
    self.present(deleteAlert, animated: true) {
      self.clearCacheButton.isEnabled = FileManager.default.fileExists(atPath: User.files.fratImageURL.path)
    }
    deleteAlert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
  }
  fileprivate func clearCache() {
    if FileManager.default.fileExists(atPath: User.files.fratImageURL.path) {
      do {
        try FileManager.default.removeItem(at: User.files.fratImageURL)
//        print("Cache cleared!")
      }
      catch let e {
        print(e.localizedDescription)
      }
    }
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


