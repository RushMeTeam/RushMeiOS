//
//  PrivacyViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 5/28/18.
//  Copyright © 2018 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
  
  @IBOutlet weak var privacyStatementTextView: UITextView!
  
  @IBOutlet weak var disagreeButton: UIBarButtonItem!
  
  @IBOutlet weak var agreeButton: UIBarButtonItem!
  
  @IBOutlet weak var subLabel: UILabel!
  override func viewDidAppear(_ animated: Bool) {
    if let _ = RushMe.privacy.policy,
      let _ =  RushMe.privacy.policyDate {
      self.privacyStatementTextView.text = RushMe.privacy.policy!
      self.subLabel.text = "Last Updated " + RushMe.dateFormatter.string(from: RushMe.privacy.policyDate!)
      if !(RushMe.privacy.policyIsMandatory ?? false) {
        self.disagreeButton.isEnabled = true
      }
    }
    else {
      self.privacyStatementTextView.text = "Oops! There should be something here!"
      self.subLabel.text = "Something went wrong... Please try again."
    }
    self.agreeButton.isEnabled = true
  }
  override func viewWillAppear(_ animated: Bool) {
    self.disagreeButton.isEnabled = false
    self.agreeButton.isEnabled = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  @IBAction func agree(_ sender: UIBarButtonItem) {
    RushMe.privacy.policyAccepted = true
  }
  @IBAction func disagree(_ sender: UIBarButtonItem) {
    RushMe.privacy.policyAccepted = false
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
