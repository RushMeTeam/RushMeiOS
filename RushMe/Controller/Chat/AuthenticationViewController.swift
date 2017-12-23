//
//  AuthenticationViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/16/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import FirebaseAuth


class AuthenticationViewController: UIViewController {
  
  @IBOutlet var signInButton: UIBarButtonItem!
  var tryNumber = 0
  @IBAction func signIn(_ sender: UIBarButtonItem) {
    for field in inputTextFields {
      field.resignFirstResponder()
      field.isEnabled = false
    }  
    if let email = self.usernameField.text, let password = self.passwordField.text {
      do {
        try Auth.auth().signOut()
      }
      catch let e {
        print(e.localizedDescription) 
      }
      Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
        if let _ = error {
          print(error!) 
          self.title = "Try Again..."
          self.tryNumber += 1
          
          if self.tryNumber > 3 {
            self.signInButton.isEnabled = false
            self.title = "Take a Walk"
          }
        }
        else if let _ = user {
          UniqueUser.shared.user = user
          UniqueUser.shared.username = user?.email ?? "No Email Provided"
          self.dismiss(animated: true, completion: nil)
        }
      })
    }
  }
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.signInButton.isEnabled = false
    self.navigationController?.navigationBar.titleTextAttributes =
      [NSAttributedStringKey.foregroundColor: RMColor.NavigationItemsColor]
    usernameField.becomeFirstResponder()
    // Do any additional setup after loading the view.
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    usernameField.resignFirstResponder()
    passwordField.resignFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var passwordField: UITextField!
  @IBOutlet var inputTextFields: [UITextField]!
  
  func textFieldsDidChange() {
    var hasText = true
    for field in inputTextFields {
      hasText = hasText && ((field.text?.count ?? 0) > RMUser.minPassLength)
    }
    self.signInButton.isEnabled = hasText
    
  }
  
  @IBAction func editingChanged(_ sender: UITextField) {
    self.textFieldsDidChange()
  }
  @IBAction func editingTextFields(_ sender: UITextField) {
    self.textFieldsDidChange()
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
