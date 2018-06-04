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
  @IBOutlet weak var dateLabel: UILabel!


  @IBOutlet weak var appVersionLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let buildVersion = (RMUserDevice().deviceInfo["appv"] as! String).split(separator: "-")
    appVersionLabel.text = "RushMe Version \(buildVersion[0]) Build \(buildVersion[1])"
    //if (self.revealViewController() != nil) {
      // Allow drawer button to toggle the lefthand drawer menu
      // Allow drag to open drawer, tap out to close
//      view.addGestureRecognizer(revealViewController().panGestureRecognizer())
//      view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    //}
  
    // Visual details
    self.qualityPicker.tintColor = RMColor.AppColor
    self.displayPastEventsSwitch.tintColor = RMColor.AppColor
    self.displayPastEventsSwitch.onTintColor = RMColor.AppColor
    // Update UI to match current settings
    dateLabel.text = DateFormatter.localizedString(from: RMDate.Today, dateStyle: .medium, timeStyle: .short)
    displayPastEventsSwitch.isOn = Campus.shared.considerPastEvents
    if Campus.downloadedImageQuality == .High {
     qualityPicker.selectedSegmentIndex = 2
    }
    if Campus.downloadedImageQuality == .Medium {
      qualityPicker.selectedSegmentIndex = 1
    }
    if Campus.downloadedImageQuality == .Low {
      qualityPicker.selectedSegmentIndex = 0
    }
    fraternitiesAlphabeticalSwitch.isOn = RushMe.shuffleEnabled
    clearCacheButton.isEnabled = FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path)
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
    Campus.shared.considerPastEvents = displayPastEventsSwitch!.isOn
    
    RushMe.shuffleEnabled = fraternitiesAlphabeticalSwitch.isOn
  }

  @IBAction func shuffleFraternitiesSwitch(_ sender: UISwitch) {
    RushMe.shuffleEnabled = sender.isOn
  }
  
  @IBAction func displayPastEventsSwitched(_ sender: UISwitch) {
    Campus.shared.considerPastEvents = sender.isOn
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet weak var fraternitiesAlphabeticalSwitch: UISwitch!
  
  @IBOutlet weak var clearCacheButton: UIButton!
  @IBAction func clearCache(_ sender: UIButton) {
    var fileSize = 0.0
    var fileNumber = 0
    let _ = FileManager.default.subpaths(atPath: RMFileManagement.fratImageURL.path)?.forEach({ (fileName) in
      fileSize += ((try? FileManager.default.attributesOfItem(atPath: RMFileManagement.fratImageURL.appendingPathComponent(fileName).path)[FileAttributeKey.size] as? Double ?? nil) ?? nil) ?? 0
      fileNumber += 1
    })
    let deleteAlert = UIAlertController.init(title: String(format: "Free %.1f mb", fileSize/1000000.0), message: nil, preferredStyle: .actionSheet)
    deleteAlert.addAction(UIAlertAction.init(title: "Delete \(fileNumber) image\((fileNumber > 1 ? "s" : ""))", style: .destructive, handler: { (action) in
      self.clearCache()
    }))
    self.present(deleteAlert, animated: true) {
      self.clearCacheButton.isEnabled = FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path)
    }
    deleteAlert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
  }
  fileprivate func clearCache() {
    if FileManager.default.fileExists(atPath: RMFileManagement.fratImageURL.path) {
      do {
        try FileManager.default.removeItem(at: RMFileManagement.fratImageURL)
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


