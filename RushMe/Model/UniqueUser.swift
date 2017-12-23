//
//  UniqueUser.swift
//  RushMe
//
//  Created by Adam Kuniholm on 12/16/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
import FirebaseAuth
fileprivate let sharedUserInstance = UniqueUser(openFromFile: true)

class UniqueUser: NSObject {
  var fratSignInEnabled : Bool = false {
    didSet {
     self.saveUser() 
    }
  }
  var user : User? = nil {
    didSet {
     self.saveUser() 
    }
  }
  var anonymousUser : User? = nil 
  static var shared : UniqueUser {
    get {
      return sharedUserInstance
    }
  }
  var username : String? = "No Username" {
    didSet {
      self.saveUser() 
    } 
  }
  var password : String? = "No Password" {
    didSet {
      self.saveUser() 
    } 
  }
    

  fileprivate convenience init(openFromFile : Bool = false) {
    self.init()
    let dict = UniqueUser.loadUser() 
    if let signInEnabled = dict?["fratSignInEnabled"] {
      self.fratSignInEnabled = signInEnabled == "true" ? true : false
    }
  }
  
  deinit {
    
  }
  
  func saveUser() {
    DispatchQueue.global().async {
      var dict = Dictionary<String, String>() 
      dict["fratSignInEnabled"] = self.fratSignInEnabled ? "true" : "false"
      let isSuccessfulSave =  NSKeyedArchiver.archiveRootObject(dict, toFile: RMFileManagement.userInfoURL.path)
      if !isSuccessfulSave {
        print("Errors with saving UniqueUser!")
      }
    }
  }
  static private func loadUser() -> Dictionary<String, String>? {
    if let user = NSKeyedUnarchiver.unarchiveObject(withFile: RMFileManagement.userInfoURL.path) as? Dictionary<String, String> {
      return user 
    }
    else {
      print("Failed to load user")
      return nil
    }
  }

}


